defmodule Inconn2Service.Dashboards.DashboardCharts do

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Dashboards.NumericalData
  alias Inconn2Service.AssetConfig

  #Energy meters
  def get_energy_consumption(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_energy_consumption_data(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  def get_energy_cost(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_energy_cost_for_assets(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  def get_energy_performance_indicator(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_energy_performance_indicator(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  def get_top_three_consumers(params, prefix) do
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list = form_date_list(from_date, to_date)

    top_three_assets = get_top_three_assets(from_date, to_date, params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_energy_consumption_for_assets(&1, top_three_assets, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  def get_water_consumption(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_water_consumption_data(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  def get_water_cost(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_water_cost_for_assets(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  def get_fuel_consumption(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_fuel_consumption_data(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  def get_fuel_cost(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_fuel_cost_for_assets(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  def get_consumption_for_submeters(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_consumption_for_submeters_assets(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end


  defp get_individual_energy_consumption_data(date, params, prefix) do
    config = get_site_config_for_dashboards(params["site_id"], prefix)
    energy_main_meters = convert_nil_to_list(config["energy_main_meters"])
    value =
      NumericalData.get_energy_consumption_for_assets(
                      energy_main_meters,
                      NaiveDateTime.new!(date, ~T[00:00:00]),
                      NaiveDateTime.new!(date, ~T[23:59:59]),
                      prefix)
      |> change_nil_to_zero()

    %{
      label: date,
      dataSets: [
        %{
          name: "Energy Consumption",
          value: value
        }
      ]
    }
  end

  defp get_individual_energy_cost_for_assets(date, params, prefix) do
    config = get_site_config_for_dashboards(params["site_id"], prefix)
    energy_cost_per_unit = change_nil_to_zero(config["energy_cost_per_unit"])
    asset_ids = convert_nil_to_list(params["asset_ids"])

    data_sets =
          Enum.map(asset_ids, fn asset_id ->
            energy_consumption = NumericalData.get_energy_consumption_for_asset(
                                    asset_id,
                                    NaiveDateTime.new!(date, ~T[00:00:00]),
                                    NaiveDateTime.new!(date, ~T[23:59:59]),
                                    prefix)
                                  |> change_nil_to_zero()
            %{
              name: AssetConfig.get_equipment!(asset_id, prefix).name,
              value: energy_consumption * energy_cost_per_unit
            }

          end)

    %{
      label: date,
      dataSets: data_sets
    }

  end

  defp get_individual_energy_performance_indicator(date, params, prefix) do
    config = get_site_config_for_dashboards(params["site_id"], prefix)
    energy_main_meters = convert_nil_to_list(config["energy_main_meters"])
    energy_consumption =
      NumericalData.get_energy_consumption_for_assets(
                      energy_main_meters,
                      NaiveDateTime.new!(date, ~T[00:00:00]),
                      NaiveDateTime.new!(date, ~T[23:59:59]),
                      prefix)
      |> change_nil_to_zero()

      area_in_sqft = change_nil_to_one(config["area"])
      epi = energy_consumption / area_in_sqft

    %{
      label: date,
      dataSets: [
        %{
          name: "EPI",
          value: epi
        }
      ]
    }
  end

  defp get_individual_water_consumption_data(date, params, prefix) do
    config = get_site_config_for_dashboards(params["site_id"], prefix)
    water_main_meters = convert_nil_to_list(config["water_main_meters"])
    value =
      NumericalData.get_water_consumption_for_assets(
                      water_main_meters,
                      NaiveDateTime.new!(date, ~T[00:00:00]),
                      NaiveDateTime.new!(date, ~T[23:59:59]),
                      prefix)
      |> change_nil_to_zero()

    %{
      label: date,
      dataSets: [
        %{
          name: "Water Consumption",
          value: value
        }
      ]
    }
  end

  defp get_individual_water_cost_for_assets(date, params, prefix) do
    config = get_site_config_for_dashboards(params["site_id"], prefix)
    water_cost_per_unit = change_nil_to_zero(config["water_cost_per_unit"])
    asset_ids = convert_nil_to_list(params["asset_ids"])

    data_sets =
          Enum.map(asset_ids, fn asset_id ->
            water_consumption = NumericalData.get_water_consumption_for_asset(
                                    asset_id,
                                    NaiveDateTime.new!(date, ~T[00:00:00]),
                                    NaiveDateTime.new!(date, ~T[23:59:59]),
                                    prefix)
                                  |> change_nil_to_zero()
            %{
              name: AssetConfig.get_equipment!(asset_id, prefix).name,
              value: water_consumption * water_cost_per_unit
            }

          end)

    %{
      label: date,
      dataSets: data_sets
    }

  end

  defp get_individual_fuel_consumption_data(date, params, prefix) do
    config = get_site_config_for_dashboards(params["site_id"], prefix)
    fuel_main_meters = convert_nil_to_list(config["fuel_main_meters"])
    value =
      NumericalData.get_fuel_consumption_for_assets(
                      fuel_main_meters,
                      NaiveDateTime.new!(date, ~T[00:00:00]),
                      NaiveDateTime.new!(date, ~T[23:59:59]),
                      prefix)
      |> change_nil_to_zero()

    %{
      label: date,
      dataSets: [
        %{
          name: "Fuel Consumption",
          value: value
        }
      ]
    }
  end

  defp get_individual_fuel_cost_for_assets(date, params, prefix) do
    config = get_site_config_for_dashboards(params["site_id"], prefix)
    fuel_cost_per_unit = change_nil_to_zero(config["fuel_cost_per_unit"])
    asset_ids = convert_nil_to_list(params["asset_ids"])

    data_sets =
          Enum.map(asset_ids, fn asset_id ->
            fuel_consumption = NumericalData.get_fuel_consumption_for_asset(
                                    asset_id,
                                    NaiveDateTime.new!(date, ~T[00:00:00]),
                                    NaiveDateTime.new!(date, ~T[23:59:59]),
                                    prefix)
                                  |> change_nil_to_zero()
            %{
              name: AssetConfig.get_equipment!(asset_id, prefix).name,
              value: fuel_consumption * fuel_cost_per_unit
            }

          end)

    %{
      label: date,
      dataSets: data_sets
    }

  end

  defp get_top_three_assets(from_date, to_date, site_id, prefix) do
    config = get_site_config_for_dashboards(site_id, prefix)

    energy_meters = convert_nil_to_list(config["energy_main_meters"])
                    |> AssetConfig.list_equipments_not_in_given_ids(prefix)

    asset_and_energy_list =
            energy_meters
            |> Stream.map(&Task.async(fn -> get_energy_for_each_asset(&1, from_date, to_date, prefix) end))
            |> Stream.map(&Task.await/1)
            |> Enum.sort_by(fn {_asset, value} -> value end, :desc)

    {asset_1, _value} = Enum.at(asset_and_energy_list, 0)
    {asset_2, _value} = Enum.at(asset_and_energy_list, 1)
    {asset_3, _value} = Enum.at(asset_and_energy_list, 2)

    [asset_1, asset_2, asset_3] |> Enum.filter(&(not is_nil(&1)))
  end

  defp get_energy_for_each_asset(asset, from_date, to_date, prefix) do
    {
      asset,
      NumericalData.get_energy_consumption_for_asset(
          asset.id,
          NaiveDateTime.new!(from_date, ~T[00:00:00]),
          NaiveDateTime.new!(to_date, ~T[23:59:59]),
          prefix)
          |> change_nil_to_zero()
    }
  end

  defp get_individual_energy_consumption_for_assets(date, assets, prefix) do
    data_sets =
          Enum.map(assets, fn asset ->
            energy_consumption = NumericalData.get_energy_consumption_for_asset(
                                    asset.id,
                                    NaiveDateTime.new!(date, ~T[00:00:00]),
                                    NaiveDateTime.new!(date, ~T[23:59:59]),
                                    prefix)
                                  |> change_nil_to_zero()
            %{
              name: asset.name,
              value: energy_consumption
            }
          end)

    %{
      label: date,
      dataSets: data_sets
    }
  end

  defp get_individual_consumption_for_submeters_assets(date, params, prefix) do
    get_site_config_for_dashboards(params["site_id"], prefix)
    asset_ids = convert_nil_to_list(params["asset_ids"])

    data_sets =
          Enum.map(asset_ids, fn asset_id ->
            energy_consumption = NumericalData.get_energy_consumption_for_asset(
                                    asset_id,
                                    NaiveDateTime.new!(date, ~T[00:00:00]),
                                    NaiveDateTime.new!(date, ~T[23:59:59]),
                                    prefix)
                                  |> change_nil_to_zero()
            %{
              name: AssetConfig.get_equipment!(asset_id, prefix).name,
              value: energy_consumption
            }
          end)

    %{
      label: date,
      dataSets: data_sets
    }

  end

  def get_ppm_chart(params, prefix) do
    case params["asset_category_ids"] do
      nil -> get_ppms_for_assets(params, prefix)
      _ -> get_ppms_using_asset_category_ids(params, prefix)
    end
  end

  def get_open_workorder_chart(params, prefix) do
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)
      NumericalData.get_workorder_for_chart(
        params["site_id"],
        from_date,
        to_date,
        params["asset_category_ids"],
        nil,
        nil,
        [],
        nil,
        prefix) |> group_by_asset_category("open/ip")
  end

  def get_ticket_open_status_chart(params, prefix) do
    {from_date_time, to_date_time} =
      get_site_date_time(params["from_date"], params["to_date"], params["site_id"], prefix)
    NumericalData.get_work_requests(
      params["site_id"],
      from_date_time,
      to_date_time,
      prefix
    ) |> group_by_ticket_category("open/ip/ticket")
  end

  defp get_ppms_for_assets(params, prefix) do
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)
    location_ids = Stream.filter(params["asset_ids"], fn obj ->  obj["type"] == "L" end) |> Enum.map(fn l -> l["id"] end)
    equipment_ids = Stream.filter(params["asset_ids"], fn obj ->  obj["type"] == "E" end) |> Enum.map(fn e -> e["id"] end)
    location_workorders =
      NumericalData.get_workorder_for_chart(
        params["site_id"],
        from_date,
        to_date,
        nil,
        location_ids,
        "L",
        [],
        nil,
        prefix) |> group_by_asset("scheduled/completed", "L", prefix)

    equipment_workorders =
      NumericalData.get_workorder_for_chart(
        params["site_id"],
        from_date,
        to_date,
        nil,
        equipment_ids,
        "E",
        [],
        nil,
        prefix) |> group_by_asset("scheduled/completed", "E", prefix)
    # Map.merge(location_workorders, equipment_workorders)
    IO.inspect(equipment_workorders)
    location_workorders ++ equipment_workorders
  end

  defp get_ppms_using_asset_category_ids(params, prefix) do
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)
      NumericalData.get_workorder_for_chart(
        params["site_id"],
        from_date,
        to_date,
        params["asset_category_ids"],
        nil,
        nil,
        [],
        nil,
        prefix) |> group_by_asset_category("scheduled/completed")
  end

  defp group_by_asset(work_orders, organize_for, asset_type, prefix) do
    Enum.group_by(work_orders, &(&1.asset_id))
    |> Enum.map(fn {asset_id, work_orders} ->
          %{
            label: AssetConfig.get_asset_by_type(asset_id, asset_type, prefix).name,
            datasets: calculate_datasets(work_orders, organize_for)
          }
      end)
  end

  defp group_by_asset_category(work_orders, organize_for) do
    Enum.group_by(work_orders, &(&1.asset_category_id))
    |> Enum.map(fn {_asset_id, info} ->
          wo_list = Enum.map(info, fn i -> i.work_order end)
          %{
            label: List.first(info).asset_category_name,
            datasets: calculate_datasets(wo_list, organize_for)
          }
      end)
  end

  def group_by_ticket_category(work_requests, organize_for) do
    Enum.group_by(work_requests, &(&1.workrequest_category_id))
    |> Enum.map(fn { _asset_category_id, tickets } ->
        %{
          label: List.first(tickets).workrequest_category.name,
          datasets: calculate_datasets(work_requests, organize_for)
        }
    end)
  end

  defp calculate_datasets(work_orders, "scheduled/completed") do
    [
      %{
        name: "Scheduled",
        value: work_orders |> Enum.count()
      },
      %{
        name: "Completed",
        value: Stream.filter(work_orders, fn wo -> wo.status == "cp" end) |> Enum.count()
      }
    ]
  end

  defp calculate_datasets(work_orders, "open/ip") do
    [
      %{
        name: "Tickets",
        value: div(Enum.map(work_orders, fn wo -> wo.status not in ["cr", "as"] end) |> Enum.count(), Enum.count(work_orders)) * 100
      }
    ]
  end

  defp calculate_datasets(work_requests, "open/ip/ticket") do
    [
      %{
        name: "Open",
        value: Stream.filter(work_requests, fn wr -> wr.status not in ["CP"] end) |> Enum.count()
      },
      %{
        name: "In Progress",
        value: Stream.filter(work_requests, fn wr -> wr.status not in ["CR", "CP"] end) |> Enum.count()
      },
      %{
        name: "Completed",
        value: Stream.filter(work_requests, fn wr -> wr.status in ["CP"] end) |> Enum.count()
      }
    ]
  end

  # defp calculate_datasets(work_orders, "scheduled/completed") do
  #   [
  #     %{
  #       name: "Scheduled",
  #       value: Stream.filter(work_orders, fn wo -> wo.status == "cp" end) |> Enum.count()
  #     },
  #     %{
  #       name: "Completed",
  #       value: Stream.filter(work_orders, fn wo -> wo.status not in ["cp", "cl"] end) |> Enum.count()
  #     }
  #   ]
  # end

  # def get_inprogress_to_completed_chart(site_id, params, prefix) do
  #   {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)
  #   work_orders =
  #     NumericalData.get_workorder_for_chart(
  #       params["site_id"],
  #       from_date,
  #       to_date,
  #       params["asset_category_ids"],
  #       nil,
  #       nil,
  #       [],
  #       nil,
  #       prefix)

  #   Enum.group_by(work_orders, &(&1.asset_category_id))
  #   |> Stream.map(fn {asset_category_id, work_orders} ->
  #         %{
  #           label: asset_category_id,
  #           datasets: calculate_datasets(work_orders)
  #         }
  #     end)
  # end

end
