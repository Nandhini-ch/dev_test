defmodule Inconn2Service.Dashboards do
  import Ecto.Query, warn: false

  alias Inconn2Service.Repo
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.{AssetStatusTrack, Location, Equipment}
  alias Inconn2Service.AssetConfig.{Location, Equipment}
  alias Inconn2Service.Ticket
  alias Inconn2Service.Workorder.WorkOrder
  alias Inconn2Service.Ticket.WorkRequest
  alias Inconn2Service.Measurements.MeterReading

  def ticket_linear_chart(prefix, query_params) do
    main_query = from wo in WorkOrder, where: wo.type == "TKT",
    join: wr in WorkRequest, on: wo.work_request_id == wr.id,
    select: %{work_order: wo, work_request: wr}

    query_params = rectify_query_params(query_params)


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

    {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)

    open_complaints_against_categories =
      Enum.map(grouped_by_tickets, fn {key, value} ->
        workrequest_category = Ticket.get_workrequest_category!(key, prefix)
        %{
          workrequest_category_name: workrequest_category.name,
          value: Enum.count(value)
        }
      end)

    # %{
    #   labels: ["Open Ticket Count", "Closed Ticket Count"],
    #   datasets: [open_ticket_count, closed_ticket_count],
    #   total_count: Enum.count(work_orders),
    #   additional_information: %{
    #     reopened_tickets: reopened_tickets,
    #     open_complaints_against_categories: open_complaints_against_categories
    #   }
    # }

    data_available =
      case length(work_orders) do
        0 ->
          false

        _ ->
          true
      end

    %{
      data_available: data_available,
      dataset: [
        %{name: "Open", y: open_ticket_count},
        %{name: "Closed", y: closed_ticket_count}
      ],
      total_count: Enum.count(work_orders),
      additional_information: %{
        reopened_tickets: reopened_tickets,
        open_complaints_against_categories: open_complaints_against_categories
      },
      labels: form_date_list(from_date, to_date)
    }
  end

  def work_order_linear_chart(prefix, query_params) do
    main_query = from wo in WorkOrder, where: wo.type not in ["TKT"]

    query_params = rectify_query_params(query_params)


    dynamic_query = get_dynamic_query_for_workflow(main_query, query_params, prefix)

    work_orders =
      apply_dates_to_workflow_query(dynamic_query, query_params, prefix) |> Repo.all(prefix: prefix)

    completed_work_orders = Enum.filter(work_orders, fn wo -> wo.status == "cp" end) |> Enum.count()
    incomplete_work_orders = Enum.filter(work_orders, fn wo -> wo.status not in ["cp", "cl"] end) |> Enum.count()

    completed_overdue_work_orders = Enum.filter(work_orders, fn wo -> wo.overdue == true end) |> Enum.count()

    total_count = Enum.count(work_orders)

    open_work_orders_with_asset =
      Enum.filter(work_orders, fn wo -> wo.status not in ["cp", "cl"] end)
      |> Enum.map(fn wo ->
          asset =
            case wo.asset_type do
              "L" ->
                AssetConfig.get_location(wo.asset_id, prefix)

              "E" ->
                AssetConfig.get_equipment(wo.asset_id, prefix)
            end

            asset_category = AssetConfig.get_asset_category!(asset.asset_category_id, prefix)
            Map.put_new(wo, :asset_category, asset_category)
        end)
        |> Enum.group_by(&(&1.asset_category.name))

    open_count_with_asset_category =
      Enum.map(open_work_orders_with_asset, fn {key, value} ->
        %{
          asset_category: key,
          count: length(value)
        }
      end)


    completed_percentage =
      if total_count != 0 do
        completed_work_orders / total_count * 100 |> Float.ceil(2)
      else
        0
      end

    completed_overdue_percentage =
      if total_count != 0 do
        completed_overdue_work_orders / total_count * 100 |> Float.ceil(2)
      else
        0
      end

    {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)


    data_available =
      case total_count do
        0 ->
          false

        _ ->
          true
      end

    %{
      data_available: data_available,
      dataset: [
        %{name: "Completed", y: completed_work_orders},
        %{name: "Incomplete", y: incomplete_work_orders}
      ],
      total_count: total_count,
      additional_information: %{
        completed_work_orders: %{
          number: completed_work_orders,
          percentage: completed_percentage
        },
        completed_overdue_work_orders: %{
          number: completed_overdue_work_orders,
          precentage: completed_overdue_percentage
        },
        open_count_with_asset_category: open_count_with_asset_category
      },
      labels: form_date_list(from_date, to_date)
    }
  end


  def get_asset_working_hours_pie_chart(prefix, query_params) do
    equipments = get_equipment_working_hours(prefix, query_params)
    locations = get_location_working_hours(prefix, query_params)


    available_hours =
      Enum.map(equipments ++ locations,
        fn e -> get_hours_for_asset(e, "AVAILABLE", query_params, prefix)
        end) |> calculate_average()

    not_available_hours =
      Enum.map(equipments ++ locations,
        fn e -> get_hours_for_asset(e,  "NOT AVAILABLE", query_params, prefix)
        end) |> calculate_average()

    critical_assets =
      Enum.map(equipments ++ locations,
      fn e -> check_criticality_assets(e, prefix)
      end) |> Enum.filter(fn x -> x != "ND" end)

    # %{
    #   labels: ["Available", "Not Available"],
    #   datasets: [available_hours, not_available_hours],
    #   additional_assets: %{
    #     critical_assets_information: critical_assets,
    #   }
    # }

    %{
      # data_available: data_available,
      dataset: [
        %{name: "Available", y: Float.ceil(available_hours, 2)},
        %{name: "Not Available", y: Float.ceil(not_available_hours)}
      ],
      additional_assets: %{
        critical_assets_information: critical_assets,
      }
    }
  end

  def calculate_average(list) do
    if length(list) == 0 do
      0.0
    else
      Enum.sum(list)/length(list)
    end
  end

  def check_criticality_assets(asset, prefix) do
    query =
      from(ast in AssetStatusTrack,
          where: ast.asset_id == ^asset.id and
                ast.asset_type == ^asset.asset_type,
                order_by: [desc: ast.changed_date_time], limit: 1)

    last_entry = Repo.one(query, prefix: prefix)

    if last_entry.status_changed not in ["ON", "OFF"] do
      time_zone = AssetConfig.get_site_time_zone_from_asset(asset.site_id, prefix)
      {:ok, current_date} = DateTime.now(time_zone)
      %{
        asset_name: asset.name,
        no_of_days_inactive: NaiveDateTime.diff(DateTime.to_naive(current_date), last_entry.changed_date_time)
      }
    else
      "ND"
    end
  end


  def get_equipment_working_hours(prefix, query_params) do
    main_query = from e in Equipment

    query_params = rectify_query_params(query_params)

    get_dynamic_query_for_assets(main_query, query_params)
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn a -> Map.put_new(a, :asset_type, "E") end)
  end

  def get_location_working_hours(prefix, query_params) do
    main_query = from l in Location

    query_params = rectify_query_params(query_params)

    get_dynamic_query_for_assets(main_query, query_params)
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn a -> Map.put_new(a, :asset_type, "L") end)
  end


  def get_hours_for_asset(asset, type, query_params, prefix) do
    query_params = rectify_query_params(query_params)

    {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)

    from_naive = NaiveDateTime.new!(from_date, Time.new!(0, 0, 0))
    to_naive = NaiveDateTime.new!(to_date, Time.new!(23, 59, 59))


    status_changes =
      from(ast in AssetStatusTrack, where: ast.asset_id == ^asset.id and ast.asset_type == ^asset.asset_type and ast.changed_date_time >= ^from_naive and ast.changed_date_time <= ^to_naive)
      |> Repo.all(prefix: prefix)

    case type do
      "AVAILABLE" ->
        Enum.filter(status_changes, fn sc -> sc.status_changed in ["ON", "OFF"] end)
        |> Enum.map(fn sc -> sc.hours end) |> Enum.sum() |> add_current_time_to_status_changes(asset, type, status_changes, from_naive, to_naive, prefix)

      "NOT AVAILABLE" ->
        Enum.filter(status_changes, fn sc -> sc.status_changed not in ["ON", "OFF"] end)
        |> Enum.map(fn sc -> sc.hours end) |> Enum.sum() |> add_current_time_to_status_changes(asset, type, status_changes, from_naive, to_naive, prefix)
    end
  end

  def add_current_time_to_status_changes(_sum, asset, "AVAILABLE", [], from_naive, to_naive, prefix) do
    query =
      from(ast in AssetStatusTrack,
          where: ast.asset_id == ^asset.id and
                ast.asset_type == ^asset.asset_type,
                order_by: [desc: ast.changed_date_time], limit: 1)

    last_entry = Repo.one(query, prefix: prefix)

    cond do
      last_entry != nil and last_entry.status_changed in ["ON", "OFF"] ->
        IO.inspect(NaiveDateTime.diff(to_naive, from_naive) / 3600)
        NaiveDateTime.diff(to_naive, from_naive) / 3600

      true ->
        0
    end
  end


  def add_current_time_to_status_changes(_sum, asset, "NOT AVAILABLE", [], from_naive, to_naive, prefix) do
    query =
      from(ast in AssetStatusTrack,
          where: ast.asset_id == ^asset.id and
                ast.asset_type == ^asset.asset_type,
                order_by: [desc: ast.changed_date_time], limit: 1)

    last_entry = Repo.one(query, prefix: prefix)

    cond do
      last_entry.status_changed not in ["ON", "OFF"] ->
        IO.inspect(NaiveDateTime.diff(to_naive, from_naive) / 3600)
        NaiveDateTime.diff(to_naive, from_naive) / 3600


      true ->
        0
    end
  end

  def add_current_time_to_status_changes(sum, asset, _type, status_changes, _from_naive, _to_naive, prefix) do
    length_of_status_changes = length(status_changes)
    last_status = Enum.at(status_changes, length_of_status_changes - 1)

    time_zone = AssetConfig.get_site_time_zone_from_asset(asset.site_id, prefix)

    {:ok, date_time} = DateTime.now(time_zone)

    NaiveDateTime.diff(DateTime.to_naive(date_time), last_status.changed_date_time) / 3600 + sum
  end


  def get_locations_assets(prefix, query_params) do
    main_query = from l in Location
    dynamic_query = get_dynamic_query_for_assets(main_query, rectify_query_params(query_params))
    Repo.all(dynamic_query, prefix: prefix) |> Enum.map( fn a -> Map.put_new(a, :asset_type, "L") end)
  end


  def get_equipment_assets(prefix, query_params) do
    main_query = from e in Equipment
    dynamic_query = get_dynamic_query_for_assets(main_query, rectify_query_params(query_params))
    Repo.all(dynamic_query, prefix: prefix) |> Enum.map( fn a -> Map.put_new(a, :asset_type, "E") end)
  end


  defp get_dynamic_query_for_assets(main_query, query_params) do
    Enum.reduce(query_params, main_query, fn
      {"asset_category_id", asset_category_id}, main_query ->
        from q in main_query, where: q.asset_category_id == ^asset_category_id

      {"site_id", site_id}, main_query ->
        from q in main_query, where: q.site_id == ^site_id

      {"asset_id", asset_id}, main_query ->
        from q in main_query, where: q.asset_id == ^asset_id

      {"type", "current_running"}, main_query ->
        from q in main_query, where: q.status in ["ON", "OFF"]

      {"type", "critical_asset"}, main_query ->
        from q in main_query, where: q.criticality == 1

      {"type", "breakdown"}, main_query ->
        from q in main_query, where: q.status not in ["ON","OFF"]

      _ , main_query ->
        main_query
    end)
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

  defp get_dates_for_query("null", "null", site_id, prefix) do
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

  def get_energy_meter_speedometer(query_params, prefix) do
    {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)
    date_list = form_date_list(from_date, to_date)
    site_config = AssetConfig.get_site_config_by_site_id(query_params["site_id"], prefix)
    data = get_main_meter_readings(site_config, date_list, prefix)
    %{
      labels: date_list,
      data: [data]
    }
  end

  def get_main_meter_readings(site_config, date_list, prefix) when site_config != nil do
    main_meters = site_config.config["main_meters"]
    if main_meters != nil do
      Enum.map(main_meters, fn main_meter -> get_energy_meter_reading(main_meter, List.first(date_list), prefix) end)
      |> Enum.reduce(0, fn x, acc -> x + acc end)
    else
      0
    end
  end

  def get_main_meter_readings(_site_config, _date_list, _prefix), do: 0

  def get_energy_meter_reading(meter_id, date, prefix) do
    start_dt = NaiveDateTime.new!(date.year, date.month, date.day, 0, 0, 0)
    end_dt = NaiveDateTime.new!(date.year, date.month, date.day, 23, 59, 59, 999_999)
    query = from mr in MeterReading, where: mr.asset_id == ^meter_id and
                                            mr.asset_type == "E" and
                                            mr.unit_of_measurement == "kwh" and
                                            mr.recorded_date_time >= ^start_dt and mr.recorded_date_time <= ^end_dt
    meter_readings = Repo.all(query, prefix: prefix)
    Enum.map(meter_readings, fn x -> x.absolute_value end)
    |> Enum.reduce(0, fn x, acc -> x + acc end)
  end

  def get_energy_meter_linear_chart(query_params, prefix) do
    query_params = rectify_query_params(query_params)
    {from_date, to_date} = get_dates_for_query(query_params["from_date"], query_params["to_date"], query_params["site_id"], prefix)
    date_list = form_date_list(from_date, to_date)
    case query_params["type"] do
      "TOP3" ->
          get_top_three_energy_meter_linear_chart(query_params["site_id"], date_list, prefix)

      _ ->
          query = from e in Equipment
          energy_meters = Enum.reduce(query_params, query, fn
                            {"site_id", site_id}, query  ->
                              from e in query, where: e.site_id == ^site_id

                            {"asset_category_id", asset_category_id}, query ->
                              from e in query, where: e.asset_category_id == ^asset_category_id

                            {"asset_id", asset_id}, query  ->
                              from e in query, where: e.id == ^asset_id

                            _, query ->
                              query
                          end)
                          |> Repo.all(prefix: prefix)
          data = Enum.map(date_list, fn date -> get_energy_meter_reading_for_multiple_assets(energy_meters, date, prefix) end)
          {datasets, additional_info} = calculate_datasets_for_energy_meter(query_params, data, prefix)
          %{
            labels: date_list,
            datasets: [datasets],
            additional_information: [additional_info]
          }
    end
  end

  def get_energy_meter_reading_for_multiple_assets(energy_meters, date, prefix) do
    Enum.map(energy_meters, fn energy_meter -> get_energy_meter_reading(energy_meter.id, date, prefix) end)
    |> Enum.reduce(0, fn x, acc -> x + acc end)
  end


  defp calculate_datasets_for_energy_meter(query_params, data, prefix) do
    site_config = AssetConfig.get_site_config_by_site_id(query_params["site_id"], prefix)
    case query_params["type"] do
      "EC" ->
        cost = if site_config == nil do
                0
               else
                site_config.config["energy_cost_per_unit"]
               end
        data = Enum.map(data, fn x -> x * cost end)
        {
            %{
              data: data, name: "Energy Cost"
            },
            %{
              avg_value: average_value(data), name: "Energy Cost"
            }
        }
      "EPI" ->
        sq_feet = if site_config == nil do
                    1
                  else
                    site_config.config["area"]
                  end
        data = Enum.map(data, fn x -> x / sq_feet end)
        {
          %{
            data: data, name: "EPI"
          },
          %{
            avg_value: average_value(data), name: "EPI"
          }
        }

      "DEVI" ->
        standard_value = if site_config == nil do
                          0
                         else
                          site_config.config["standard_value_for_deviation"]
                         end
        data = Enum.map(data, fn x -> x - standard_value end)
        {
          %{
            data: data, name: "Deviation"
          },
          %{
            avg_value: average_value(data), name: "Deviation"
          }
        }

      _ ->
        {
          %{
            data: data, name: "kWh"
          },
          %{
            avg_value: average_value(data), name: "kWh"
          }
        }

    end
  end

  def get_top_three_energy_meter_linear_chart(site_id, date_list, prefix) do
    site_config = AssetConfig.get_site_config_by_site_id(site_id, prefix)
    cost = if site_config == nil do
            0
           else
            site_config.config["energy_cost_per_unit"]
          end
    energy_meters = from(e in Equipment, where: e.site_id == ^site_id)
                    |> Repo.all(prefix: prefix)
    top_three = Enum.map(energy_meters, fn energy_meter ->
                      get_energy_meter_reading_for_multiple_dates_single_asset(energy_meter, date_list, prefix)
                  end)
                |> Enum.sort_by(&(&1.aggregated_value), :desc)

    top1 = Enum.at(top_three, 0)
    top2 = Enum.at(top_three, 1)
    top3 = Enum.at(top_three, 2)
    %{
      labels: date_list,
      datasets:
              [
                %{
                  data: top1.data, name: top1.asset_name
                },
                %{
                  data: top2.data, name: top2.asset_name
                },
                %{
                  data: top3.data, name: top3.asset_name
                }
              ],
      additional_information:
              [
                %{name: top1.asset_name, avg_value: top1.avg_value, cost: top1.avg_value * cost},
                %{name: top2.asset_name, avg_value: top2.avg_value, cost: top2.avg_value * cost},
                %{name: top3.asset_name, avg_value: top3.avg_value, cost: top3.avg_value * cost}
              ]
      }
  end

  defp get_energy_meter_reading_for_multiple_dates_single_asset(energy_meter, date_list, prefix) do
    data = Enum.map(date_list, fn date -> get_energy_meter_reading(energy_meter.id, date, prefix) end)
    %{
      asset_name: energy_meter.name,
      data: data,
      aggregated_value: Enum.sum(data),
      avg_value: average_value(data)
    }
  end

  defp average_value(data) do
    Enum.sum(data) / length(data)
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

  defp rectify_query_params(query_params) do
    Enum.filter(query_params, fn {_key, val} -> val not in ["null", "nil", nil] end)
    |> Enum.into(%{})
  end
end
