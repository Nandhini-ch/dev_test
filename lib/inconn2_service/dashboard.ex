defmodule Inconn2Service.Dashboard do

  import Ecto.Query, warn: false

  alias Inconn2Service.Repo
  alias Inconn2Service.AssetConfig.{Location, Equipment}
  alias Inconn2Service.WorkOrderConfig.Task
  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.{WorkOrder, WorkorderTemplate, WorkorderTask}

  def work_order_pie_chart(prefix, query_params) do
    date = Date.utc_today()
    query =
      case query_params do
        %{"from_date" => from_date,  "to_date" => to_date} ->
          {:ok, converted_from_date} = date_convert(from_date)
          {:ok, converted_to_date} = date_convert(to_date)
          from wo in WorkOrder, where: wo.scheduled_date >= ^converted_from_date and wo.scheduled_date <= ^converted_to_date

        %{"from_date" => from_date} ->
          {:ok, converted_from_date} = date_convert(from_date)
          from wo in WorkOrder, where: wo.scheduled_date >= ^converted_from_date and wo.scheduled_date <= ^date

        _ ->
          from wo in WorkOrder, where: wo.scheduled_date == ^date
      end

    work_orders = Repo.all(query, prefix: prefix)
    completed_work_order_count = Enum.filter(work_orders, fn wo -> wo.status == "cp" end) |> Enum.count()
    incomplete_work_order_count = Enum.filter(work_orders, fn wo -> wo.status != "cp" end) |> Enum.count()

    %{completed_work_order_count: completed_work_order_count, incomplete_work_order_count: incomplete_work_order_count}
  end

  def work_order_bar_chart(prefix, query_params) do
    {from_date, to_date} =
      case query_params do
        %{"from_date" => from_date,  "to_date" => to_date} ->
          {:ok, converted_from_date} = date_convert(from_date)
          {:ok, converted_to_date} = date_convert(to_date)
          {converted_from_date, converted_to_date}

        %{"from_date" => from_date} ->
          {:ok, converted_from_date} = date_convert(from_date)
          {converted_from_date, Date.utc_today()}

        _ ->
          {Date.utc_today, Date.utc_today}
      end
    # work_orders = Repo.all(query, prefix: prefix) |> Enum.group_by(&(&1.scheduled_date))

    date_list = form_date_list(from_date, to_date)

    completed_work_order_counts =
      Enum.map(date_list, fn date ->
        WorkOrder |> where([scheduled_date: ^date, status: "cp"]) |> Repo.all(prefix: prefix) |> Enum.count
      end)

    incomplete_work_order_counts =
      Enum.map(date_list, fn date ->
        WorkOrder |> where([scheduled_date: ^date]) |> Repo.all(prefix: prefix) |> Enum.filter(fn wo -> wo.status != "cp" end) |> Enum.count
      end)

    %{
      completed_work_order_count: completed_work_order_counts,
      incomplete_work_order_count: incomplete_work_order_counts,
      dates: date_list
    }
  end

  def work_flow_pie_chart(prefix, query_params) do
    query = from wo in WorkOrder, join: wt in WorkorderTemplate

    work_orders =
      Enum.reduce(query_params, query, fn
        {"site_id", site_id}, query  ->
          from w in query, where: w.site_id == ^site_id

        {"type", work_order_type}, query ->
          from w in query, where: w.type == ^work_order_type

        {"asset_category_id", _}, query -> query
      end)
      |> filter_by_date(query_params["start_date"], query_params["end_date"])
      |> Repo.all(prefix: prefix)
      |> filter_by_asset_category(query_params["asset_category_id"], prefix)

    completed_work_order_count =
      Enum.filter(work_orders, fn wo -> wo.status == "cp" end) |> Enum.count()

    incomplete_work_order_count =
      Enum.filter(work_orders, fn wo -> wo.status != "cp" end) |> Enum.count()

    # %{completed_work_order_count: completed_work_order_count, incomplete_work_order_count: incomplete_work_order_count}
    %{labels: ["completed_work_order_count", "incomplete_work_order_count"], data: [completed_work_order_count, incomplete_work_order_count]}
  end

  def filter_by_asset_category(work_orders, nil, _prefix), do: work_orders

  def filter_by_asset_category(work_orders, asset_category_id, prefix) do
    Enum.filter(work_orders, fn wo ->
      workorder_template = Workorder.get_workorder_template!(wo.workorder_template_id, prefix)
      workorder_template.asset_category_id == asset_category_id
    end)
  end

  def get_trendline_for_metering(_prefix, query_params) do
    from_date =
      case query_params["from_date"] do
        nil ->
          Date.utc_today()
        date ->
          {:ok, converted_date} = date_convert(date)
          converted_date
      end
    to_date =
      case query_params["to_date"] do
        nil ->
          Date.utc_today()
        date ->
          {:ok, converted_date} = date_convert(date)
          converted_date
      end
    labels = form_date_list(from_date, to_date)
    data = Enum.map(1..length(labels), fn _x -> Enum.random(200..300) end)
  %{labels: labels, data: data}
  end

  def filter_by_date(query, nil, nil), do: query

  def filter_by_date(query, from_date, nil) do
    from w in query, where: w.scheduled_date >= ^from_date
  end


  def filter_by_date(query, from_date, to_date) do
    from w in query, where: w.scheduled_date >= ^from_date and w.scheduled_date <= ^to_date
  end

  defp date_convert(date_to_convert) do
    date_to_convert
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
    |> (fn [year, month, day] -> Date.new(year, month, day) end).()
  end

  def form_date_list(from_date, to_date) do
    list = [from_date] |> List.flatten()
    now_date = Date.add(List.last(list), 1)
    case Date.compare(now_date, to_date) do
      :gt ->
            list
      _ ->
            list ++ [now_date]
            |> form_date_list(to_date)
    end
  end

  def asset_status_pie_chart(prefix, query_params) do

    locations = query_variable_asset_status(Location, query_params, prefix)
    equipments = query_variable_asset_status(Equipment, query_params, prefix)

    assets = locations ++ equipments
    total_asset_count = Enum.count(assets)
    available_asset_count = Enum.filter(assets, fn x -> x.status in ["ON", "OFF"] end) |> Enum.count()
    # current_running_asset_count = Enum.filter(assets, fn x -> x.status == "ON" end) |> Enum.count()
    # breakdown_asset_count = Enum.filter(assets, fn x -> x.status == "BRK" end) |> Enum.count()
    # critical_asset_count = Enum.filter(assets, fn x -> x.criticality == 1 end) |> Enum.count()
    not_available_asset_count = Enum.filter(assets, fn x -> x.status not in ["ON", "OFF"] end) |> Enum.count()
    %{
      labels: ["Available", "Not Available"],
      data: [available_asset_count, not_available_asset_count],
      total_assets: total_asset_count
    }

  end

  def query_variable_asset_status(module, query_params, prefix) do
    query = from a in module

    Enum.reduce(query_params, query, fn

      {"site_id", site_id}, query ->
          from q in query, where: q.site_id == ^site_id

      {"asset_category_id", asset_category_id}, query ->
          from q in query, where: q.asset_category_id == ^asset_category_id

    end)

    |> Repo.all(prefix: prefix)
  end

  # def get_trendline_for_metering(_prefix, query_params) do
  #   {:ok, from_date} = date_convert(query_params["from_date"])
  #   {:ok, to_date} = date_convert(query_params["to_date"])
  #   labels = form_date_list(from_date, to_date)
  #   data = Enum.map(1..length(labels), fn _x -> Enum.random(200..300) end)
  # %{labels: labels, data: data}
  # end

# "$$$$$$$$$$$$$$$$$$$$$$$$$$"
  def get_metering_linear_chart(prefix, query_params) do
    {from_date, to_date} =
      case query_params do
        %{"from_date" => from_date,  "to_date" => to_date} ->
          {:ok, converted_from_date} = date_convert(from_date)
          {:ok, converted_to_date} = date_convert(to_date)
          {converted_from_date, converted_to_date}

        %{"from_date" => from_date} ->
          {:ok, converted_from_date} = date_convert(from_date)
          {converted_from_date, Date.utc_today()}

        _ ->
          {Date.utc_today, Date.utc_today}
      end

    date_list = form_date_list(from_date, to_date)
    # asset_id = query_params["asset_id"]

    # if asset_id != nil do
      work_orders = from(wo in WorkOrder, where: wo.status == "cp")
                    |> Repo.all(prefix: prefix)
                    |> Enum.map(fn wo -> preload_required(wo, prefix) end)
                    |> Enum.filter(fn wo -> wo.workorder_task != [] end)
                    |> Enum.map(fn wo -> Map.put(wo, :workorder_task, List.first(wo.workorder_task)) end)
                    |> process_recorded()
                    |> Enum.filter(fn wo -> wo.recorded_date in date_list end)
                    |> process_absolute_and_cumulative()
                    |> group_and_add_by_dates()
      data_to_be_processed = form_required_data_from_work_orders(%{labels: [], data: []}, work_orders)
      process_data_with_all_dates_in_date_range(data_to_be_processed, date_list)
      |> add_boolean()
    # else
    #   %{labels: [], data: []}
    # end
  end

  defp add_boolean(data) do
    inner_data = data.data
    filtered_data = Enum.filter(inner_data, fn x -> x != 0 end)
    if filtered_data == [] do
      Map.put(data, :data_available, false)
    else
      Map.put(data, :data_available, true)
    end
  end

  defp preload_required(work_order, prefix) do
    work_order
    |> Map.put(:workorder_template, Repo.get(WorkorderTemplate, work_order.workorder_template_id, prefix: prefix))
    |> Map.put(:workorder_task, Repo.all(from(wot in WorkorderTask, where: wot.work_order_id == ^work_order.id), prefix: prefix)
                                |> Enum.map(fn wot -> Map.put(wot, :task, Repo.get(Task, wot.task_id, prefix: prefix)) end)
                                |> Enum.filter(fn wot -> wot.task.task_type == "MT" and wot.task.config["UOM"] in ["kwh", "KWH", "KwH", "Kwh", "kWh", "kWH"] end)
                )
  end

  defp process_recorded(work_orders) do
    work_orders
    |> Enum.filter(fn wo -> wo.workorder_task.actual_end_time != nil end)
    |> Enum.sort_by(&(&1.workorder_task.actual_end_time), NaiveDateTime)
    |> Enum.map(fn wo -> Map.put(wo, :recorded_date_time, wo.workorder_task.actual_end_time) end)
    |> Enum.map(fn wo -> Map.put(wo, :recorded_date, NaiveDateTime.to_date(wo.recorded_date_time)) end)
    |> Enum.map(fn wo -> Map.put(wo, :recorded_value, wo.workorder_task.response["answers"]) end)
  end

  def group_and_add_by_dates(work_orders) do
    Enum.group_by(work_orders, &(&1.recorded_date))
    |> Enum.map(fn wo_list -> Enum.reduce(wo_list, List.first(wo_list), fn wo, acc -> Map.put(acc, :recorded_value, wo.recorded_value + acc.recorded_value) end) end)
    |> Enum.map(fn {_key, value} -> value end)
  end

  defp process_absolute_and_cumulative(work_orders) do
    grouped_by_a_and_c = Enum.group_by(work_orders, &(&1.workorder_task.task.config["type"]))
    absolute_work_orders =
          if grouped_by_a_and_c["A"] != nil do
            grouped_by_a_and_c["A"]
          else
            []
          end
    cumulative_work_orders =
          if grouped_by_a_and_c["C"] != nil do
            Enum.group_by(grouped_by_a_and_c["C"], &(&1.asset_id))
            |> Enum.map(fn {_key, value}-> calculate_absolute_metering_values([], [], value) end)
          else
            []
          end
    absolute_work_orders ++ cumulative_work_orders
    # type_of_configs = Enum.map(work_orders, fn wo -> wo.workorder_task.task.config["type"] end)
    # if "A" in type_of_configs and "C" in type_of_configs do
    #   %{labels: [], data: []}
    # else
    #   if "A" in type_of_configs do
    #     form_required_data_from_work_orders(%{labels: [], data: []}, work_orders)
    #   else
    #     work_orders = calculate_absolute_metering_values([], [], work_orders)
    #     form_required_data_from_work_orders(%{labels: [], data: []}, work_orders)
    #   end
    # end
  end

  defp form_required_data_from_work_orders(processed_data, work_orders) do
    if work_orders != [] do
      [h | t] = work_orders
      processed_data = %{labels: processed_data.labels ++ [h.recorded_date],
                         data: processed_data.data ++ [h.recorded_value]}
      form_required_data_from_work_orders(processed_data, t)
    else
      processed_data
    end
  end

  # defp calculate_absolute_metering_values(final_list, processed_list, list_to_be_processed) do
  #   if list_to_be_processed != [] do
  #       [h | t] = list_to_be_processed
  #       if final_list == [] do
  #         [0]
  #         |> calculate_absolute_metering_values([h], t)
  #       else
  #         final_list ++ [h - List.last(processed_list)]
  #         |> calculate_absolute_metering_values(processed_list ++ [h] ,t)
  #       end
  #   else
  #     final_list
  #   end
  # end

  def calculate_absolute_metering_values(final_list, processed_list, wo_list_to_be_processed) do
    if wo_list_to_be_processed != [] do
        [h | t] = wo_list_to_be_processed
        if final_list == [] do
          [Map.put(h, :recorded_value, 0)]
          |> calculate_absolute_metering_values([h], t)
        else
          final_list ++ [Map.put(h, :recorded_value, h.recorded_value - List.last(processed_list.recorded_value))]
          |> calculate_absolute_metering_values(processed_list ++ [h] ,t)
        end
    else
      final_list
    end
  end

  def process_data_with_time_range(processed_data, data_to_be_processed, date_list) do
    IO.puts("00000000000000")
    IO.inspect(processed_data)
    IO.inspect(data_to_be_processed)
    if data_to_be_processed.labels != [] and data_to_be_processed.data != [] do
      [label_head | label_tail] = data_to_be_processed.labels
      [data_head | data_tail] = data_to_be_processed.data
      if processed_data.labels == [] and processed_data.data == [] do
        if label_head in date_list do
          IO.puts("111111111111111111")
          processed_data = %{labels: [label_head], data: [data_head]}
          data_to_be_processed = %{labels: label_tail, data: data_tail}
          IO.inspect(processed_data)
          IO.inspect(data_to_be_processed)
          process_data_with_time_range(processed_data, data_to_be_processed, date_list)
        else
          IO.puts("2222222222222222222")
          date_missed = List.first(date_list)
          processed_data = %{labels: [date_missed], data: [0]}
          data_to_be_processed = %{labels: label_tail, data: data_tail}
          IO.inspect(processed_data)
          IO.inspect(data_to_be_processed)
          process_data_with_time_range(processed_data, data_to_be_processed, date_list)
        end
      else
        if label_head in date_list do
          IO.puts("333333333333333333")
          processed_data = %{labels: processed_data.labels ++ [label_head], data: processed_data.data ++ [data_head]}
          data_to_be_processed = %{labels: label_tail, data: data_tail}
          IO.inspect(processed_data)
          IO.inspect(data_to_be_processed)
          process_data_with_time_range(processed_data, data_to_be_processed, date_list)
        else
          IO.puts("444444444444444444")
          date_missed = Date.add(List.last(processed_data.labels), 1)
          processed_data = %{labels: processed_data.labels ++ [date_missed], data: processed_data.data ++ [0]}
          data_to_be_processed = %{labels: label_tail, data: data_tail}
          IO.inspect(processed_data)
          IO.inspect(data_to_be_processed)
          process_data_with_time_range(processed_data, data_to_be_processed, date_list)
        end
      end
    else
      processed_data
    end
  end

  def process_data_with_all_dates_in_date_range(data, date_list) do
    labels = data.labels
    list_of_data = label_and_data_to_list_of_maps([], data)
    grouped_data = check_dates_in_date_list(list_of_data, labels, date_list)
                   |> Enum.sort_by(&(&1.label), Date)
                   # |> Enum.reduce(fn x, acc = %{labels: [], data: []} -> %{labels: acc.labels ++ x.label, data: acc.data ++ x.datum} end)
                   |> Enum.group_by(&(&1.label))
    labels = Enum.map(grouped_data, fn {key, _value} -> key end)
    data = Enum.map(grouped_data, fn {_key, [value]} -> value.datum end)
    %{labels: labels, data: data}
  end

  def check_dates_in_date_list(list_of_data, labels, date_list) do
    if date_list != [] do
      [date_head | date_tail] = date_list
      if date_head in labels do
        check_dates_in_date_list(list_of_data, labels, date_tail)
      else
        list_of_data = list_of_data ++ [%{label: date_head, datum: 0}]
        check_dates_in_date_list(list_of_data, labels, date_tail)
      end
    else
      list_of_data
    end
  end

  def label_and_data_to_list_of_maps(processed_list, data_to_be_processed) do
    if data_to_be_processed.labels != [] and data_to_be_processed.data != [] do
      [label_head | label_tail] = data_to_be_processed.labels
      [data_head | data_tail] = data_to_be_processed.data
      processed_list = processed_list ++ [%{label: label_head, datum: data_head}]
      data_to_be_processed = %{labels: label_tail, data: data_tail}
      label_and_data_to_list_of_maps(processed_list, data_to_be_processed)
    else
      processed_list
    end
  end





# "$$$$$$$$$$$$$$$$$$$$$$$$$$"

  # def get_metering_linear_chart(prefix, query_params) do
  #   if query_params["asset_id"] != nil do
  #     query =
  #       from wt in WorkorderTemplate
  #               join: wo in WorkOrder, on: wo.workorder_template_id == wt.id,
  #               join: wot in WorkorderTask, on: wot.work_order_id == wo.id,
  #               join: t in Task, on: t.id == wot.task_id, where: t.task_type == "MT" and wo.asset_id == query_params["asset_id"],
  #                           select: %{site_id: wo.site_id,
  #                                     asset_id: wo.asset_id,
  #                                     asset_type: wo.asset_type,
  #                                     asset_category_id: wt.asset_category_id,
  #                                     workorder_template_id: wo.workorder_template_id,
  #                                     workorder_schedule_id: wo.workorder_schedule_id,
  #                                     task_id: wot.task_id,
  #                                     actual_end_time: wot.actual_end_time,
  #                                     response: wot.response,
  #                                     remarks: wot.remarks,
  #                                     config: t.config
  #                                     }
  #     work_orders = Repo.all(query, prefix: prefix)
  #                 |> Enum.filter(fn x -> x.config["UOM"] in ["kwh", "KWH", "KwH", "Kwh", "kWh", "kWH"] end)
  #     # Enum.map(grouped_work_orders, fn {_wo_s_id, list_of_wo_objects} ->

  #     #                             end)
  #   else
  #     []
  #   end
  # end

  # defp group_by_asset_category_or_asset(work_orders, query_params) do
  #   asset_id = query_params["asset_id"]
  #   asset_category_id = query_params["asset_category_id"]
  #   if asset_id != nil do
  #     Enum.filter(work_orders, fn x -> x.asset_id == asset_id end)
  #     |> Enum.group_by(:asset_id)
  #   else
  #     Enum.filter(work_orders, fn x -> x.asset_category_id == asset_category_id end)
  #     |> Enum.group_by(:asset_category_id)
  #     []
  #   end
  # end

  # def average_data(work_order_list) do
  #   Enum.group_by(work_order_list, :asset_id)
  #   # |> Enum.map({_key, value} ->  end)
  # end

  # def average_data(work_order_list) do

  # end

  # defp manipulate_work_order_list_grouped_by_schedule_id(work_order_list) do
  #   Enum.group_by(work_order_list, :task_id)
  #   |> Enum.map(fn {_task_id, list_of_wo_objects} ->
  #                              Enum.sort_by(list_of_wo_objects, &(&1.actual_end_time), NaiveDateTime)

  #               end)
  # end

end
