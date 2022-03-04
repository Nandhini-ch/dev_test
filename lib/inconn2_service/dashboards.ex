defmodule Inconn2Service.Dashboards do
  import Ecto.Query, warn: false

  alias Inconn2Service.Repo
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Ticket
  alias Inconn2Service.Workorder.WorkOrder
  alias Inconn2Service.Ticket.WorkRequest

  def ticket_linear_chart(prefix, query_params) do
    main_query = from wo in WorkOrder, where: wo.type == "TKT",
    join: wr in WorkRequest, on: wo.work_request_id == wr.id,
    select: %{work_order: wo, work_request: wr}


    dynamic_query = get_dynamic_query_for_workflow(main_query, query_params, prefix)

    work_orders =
      apply_dates_to_workflow_query(dynamic_query, query_params, prefix) |> Repo.all(prefix: prefix)


    open_tickets = Enum.filter(work_orders, fn wo -> wo.work_request.status not in ["CL", "CS"] end)


    open_ticket_count = Enum.filter(work_orders, fn wo -> wo.work_request.status not in ["CL", "CS"] end) |> Enum.count()
    closed_ticket_count = Enum.filter(work_orders, fn wo -> wo.work_request.status in ["CL", "CS"] end) |> Enum.count()
    reopened_tickets =
      Enum.filter(work_orders, fn wo -> wo.work_request.status == "RO" end)
      |> Enum.map(fn wo -> %{id: wo.work_request.id, status: wo.work_request.status} end)

    grouped_by_tickets = Enum.group_by(open_tickets, &(&1.work_request.workrequest_category_id))

    open_complaints_against_categories =
      Enum.map(grouped_by_tickets, fn {key, value} ->
        workrequest_category = Ticket.get_workrequest_category!(key, prefix)
        %{
          workrequest_category_name: workrequest_category.name,
          value: Enum.count(value)
        }
      end)

    %{
      labels: ["Open Ticket Count", "Closed Ticket Count"],
      datasets: [open_ticket_count, closed_ticket_count],
      total_count: Enum.count(work_orders),
      additional_information: %{
        reopened_tickets: reopened_tickets,
        open_complaints_against_categories: open_complaints_against_categories
      }
    }
  end

  def work_order_linear_chart(prefix, query_params) do
    main_query = from wo in WorkOrder, where: wo.type not in ["TKT"]

    dynamic_query = get_dynamic_query_for_workflow(main_query, query_params, prefix)

    work_orders =
      apply_dates_to_workflow_query(dynamic_query, query_params, prefix) |> Repo.all(prefix: prefix)

    completed_work_orders = Enum.filter(work_orders, fn wo -> wo.status == "cp" end) |> Enum.count()
    incomplete_work_orders = Enum.filter(work_orders, fn wo -> wo.status not in ["cp", "cl"] end) |> Enum.count()
    total_count = Enum.count(work_orders)

    %{
      labels: ["Completed Work Orders", "Incomplete Work Orders"],
      datasets: [completed_work_orders, incomplete_work_orders],
      total_count: total_count,
      additional_information: %{
        completed_work_orders: %{
          number: completed_work_orders,
          percentage: div(completed_work_orders,total_count) * 100
        }
      }
    }
  end

  defp get_dynamic_query_for_workflow(main_query, query_params, prefix) do
    Enum.reduce(query_params, main_query, fn
      {"asset_category_id", asset_category_id}, main_query ->
        asset_ids = asset_ids_for_asset_category(asset_category_id, prefix)
        asset_category = AssetConfig.get_asset_category(asset_category_id, prefix)
        case query_params["asset_id"] do
          nil ->
            from q in main_query, where: q.asset_id in ^asset_ids and q.asset_type == ^asset_category.asset_type

          id ->
            from q in main_query, where: q.asset_id == ^id and q.asset_type == ^asset_category.asset_type
        end

      {"site_id", site_id}, main_query ->
         from q in main_query, where: q.site_id == ^site_id

      _, main_query ->
        main_query
    end)
  end

  defp apply_dates_to_workflow_query(dynamic_query, query_params, prefix) do
    {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)
    from(q in dynamic_query, where: q.scheduled_date >= ^from_date and q.scheduled_date <= ^to_date)
  end

  defp get_dates_for_query(nil, nil, site_id, prefix) do
    site = AssetConfig.get_site!(site_id, prefix)
    {
      DateTime.now!(site.time_zone) |> DateTime.to_date() |> Date.add(-1),
      DateTime.now!(site.time_zone) |> DateTime.to_date() |> Date.add(-1)
    }
  end

  defp get_dates_for_query(from_date, nil, site_id, prefix) do
    site = AssetConfig.get_site!(site_id, prefix)
    {
      Date.from_iso8601!(from_date),
      DateTime.now!(site.time_zone) |> DateTime.to_date() |> Date.add(-1)
    }
  end

  defp get_dates_for_query(from_date, to_date, _site_id, _prefix) do
    {Date.from_iso8601!(from_date), Date.from_iso8601!(to_date)}
  end

  defp asset_ids_for_asset_category(asset_category_id, prefix) do
    AssetConfig.get_assets_by_asset_category_id(asset_category_id, prefix)
    |> Enum.map(fn a -> a.id end)
  end

  def get_energy_meter_speedometer_random(_query_parmas, _params) do
    %{
      labels: [Date.utc_today()],
      data: [Enum.random(100..1000)]
    }
  end


  def get_energy_meter_linear_chart_random(query_params, _prefix) do
    {from_date, to_date} =
            case query_params do
              %{"from_date" => from_date,  "to_date" => to_date} ->
                converted_from_date = Date.from_iso8601!(from_date)
                converted_to_date = Date.from_iso8601!(to_date)
                {converted_from_date, converted_to_date}

              %{"from_date" => from_date} ->
                converted_from_date = Date.from_iso8601!(from_date)
                {converted_from_date, Date.utc_today()}

              _ ->
                {Date.utc_today, Date.utc_today}
            end
    date_list = form_date_list(from_date, to_date)

    random =
      case query_params["type"] do
        "EC" -> 1..1000
        "EPI" -> 1..10
        "DEVI" -> -10..10
        "TOP3" ->  1..100
        _ -> 1..100
      end
    cost = Enum.random(5..30)
    data1 = Enum.map(1..length(date_list), fn _x -> Enum.random(random) end)
    data2 = Enum.map(1..length(date_list), fn _x -> Enum.random(random) end)
    data3 = Enum.map(1..length(date_list), fn _x -> Enum.random(random) end)

    avg_value1 = Enum.sum(data1) / length(data1)
    avg_value2 = Enum.sum(data2) / length(data2)
    avg_value3 = Enum.sum(data3) / length(data3)
    case query_params["type"] do
      "TOP3" ->
          %{
            labels: date_list,
            datasets: [
              %{
                data: data1, label: "Asset 1", avg_value: avg_value1, cost: avg_value1 * cost
              },
              %{
                data: data2, label: "Asset 2", avg_value: avg_value2, cost: avg_value2 * cost
              },
              %{
                data: data3, label: "Asset 3", avg_value: avg_value3, cost: avg_value3 * cost
              }
            ]
          }
      _ ->
        %{
          labels: date_list,
          datasets: [
            %{
              data: data1, label: "Asset", avg_value: avg_value1
            }
          ]
        }
    end
  end

  # def get_energy_meter_speedometer(query_params, prefix) do
  #   {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)
  #   date_list
  # end

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
end
