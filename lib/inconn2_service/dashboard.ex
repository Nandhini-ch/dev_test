defmodule Inconn2Service.Dashboard do

  import Ecto.Query, warn: false

  alias Inconn2Service.Repo
  alias Inconn2Service.AssetConfig.{Location, Equipment}
  alias Inconn2Service.Workorder.WorkOrder

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

  defp date_convert(date_to_convert) do
    date_to_convert
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
    |> (fn [year, month, day] -> Date.new(year, month, day) end).()
  end

  defp form_date_list(from_date, to_date) do
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
    current_running_asset_count = Enum.filter(assets, fn x -> x.status == "ON" end) |> Enum.count()
    breakdown_asset_count = Enum.filter(assets, fn x -> x.status == "BRK" end) |> Enum.count()
    critical_asset_count = Enum.filter(assets, fn x -> x.criticality == 1 end) |> Enum.count()

    %{
      labels: ["Total Assets", "Available", "Current running", "Breakdown", "Critical Assets"],
      data: [total_asset_count, available_asset_count, current_running_asset_count, breakdown_asset_count, critical_asset_count]
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

end
