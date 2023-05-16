defmodule Inconn2Service.Dashboards.DashboardCharts do

  @completed_workorders ["cp"]
  @open_workorders ["cr", "as", "execwa"]

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Dashboards.{NumericalData, Helpers}
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.InventoryManagement

  #Energy meters
  #Chart no 1
  def get_energy_consumption(params, prefix) do
    # cond do
    #   params["from_date"] == params["to_date"] ->


    #   true ->
        date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

        {from_time, to_time} = get_from_time_to_time_from_iso(params["from_time"], params["to_time"])

        date_list =
          case Time.compare(from_time, to_time) do
            :gt ->
              date_list |> Enum.sort() |> List.delete_at(length(date_list) - 1)

            _ ->
              date_list
          end

        date_list
        |> Enum.map(&Task.async(fn -> get_individual_energy_consumption_data(&1, params, {from_time, to_time}, prefix) end))
        |> Enum.map(&Task.await/1)
    # end
  end

  #Chart no 2
  def get_energy_cost(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_energy_cost_for_assets(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  #Chart no 3
  def get_energy_performance_indicator(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_energy_performance_indicator(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  #Chart no 4
  def get_top_three_consumers(params, prefix) do
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list = form_date_list(from_date, to_date)

    top_three_assets = get_top_three_assets(from_date, to_date, params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_energy_consumption_for_assets(&1, top_three_assets, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  #Chart no 5
  def get_water_consumption(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_water_consumption_data(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  #Chart no 6
  def get_water_cost(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_water_cost_for_assets(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  #Chart no 7
  def get_fuel_consumption(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_fuel_consumption_data(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  #Chart no 8
  def get_fuel_cost(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_fuel_cost_for_assets(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  #Chart no 9
  def get_consumption_for_submeters(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    config = get_site_config_for_dashboards(params["site_id"], prefix)

    assets = Helpers.get_sub_meter_assets(config, "E", prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_energy_consumption_for_assets(&1, assets, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  #Chart no 10
  def get_segr_for_generators(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_segr_for_generators(&1, params, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  defp get_individual_energy_consumption_data(date, params, {from_time, to_time}, prefix) do

    {from_date_time, to_date_time} = get_date_time_range_for_date_and_time_range(date, from_time, to_time)

    config = get_site_config_for_dashboards(params["site_id"], prefix)
    energy_main_meters = convert_nil_to_list(config["energy_main_meters"])
    value =
      NumericalData.get_energy_consumption_for_assets(
                      energy_main_meters,
                      from_date_time,
                      to_date_time,
                      prefix)
      |> change_nil_to_zero()

    %{
      label: date |> convert_date_format(),
      dataSets: [
        %{
          name: "Energy Consumption",
          value: convert_to_ceil_float(value)
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
            name =
              if is_map(asset_id) do
                AssetConfig.get_equipment!(asset_id["id"], prefix).name
              else
                AssetConfig.get_equipment!(asset_id, prefix).name
              end
            %{
              name: name,
              value: convert_to_ceil_float(energy_consumption * energy_cost_per_unit)
            }

          end)

    %{
      label: date |> convert_date_format(),
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

      area_in_sqft = change_nil_to_one(config["area_in_sqft"])
      epi = energy_consumption / area_in_sqft

    %{
      label: date |> convert_date_format(),
      dataSets: [
        %{
          name: "EPI",
          value: convert_to_ceil_float(epi)
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
      label: date |> convert_date_format(),
      dataSets: [
        %{
          name: "Water Consumption",
          value: convert_to_ceil_float(value)
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
              value: convert_to_ceil_float(water_consumption * water_cost_per_unit)
            }

          end)

    %{
      label: date |> convert_date_format(),
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
      label: date |> convert_date_format(),
      dataSets: [
        %{
          name: "Fuel Consumption",
          value: convert_to_ceil_float(value)
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
              value: convert_to_ceil_float(fuel_consumption * fuel_cost_per_unit)
            }

          end)

    %{
      label: date |> convert_date_format(),
      dataSets: data_sets
    }

  end

  defp get_top_three_assets(from_date, to_date, site_id, prefix) do
    config = get_site_config_for_dashboards(site_id, prefix)

    energy_meters = Helpers.get_sub_meter_assets(config, "E", prefix)

    asset_and_energy_list = Helpers.get_assets_and_energy_list(
                              energy_meters,
                              NaiveDateTime.new!(from_date, ~T[00:00:00]),
                              NaiveDateTime.new!(to_date, ~T[23:59:59]),
                              prefix)

    [Enum.at(asset_and_energy_list, 0), Enum.at(asset_and_energy_list, 1), Enum.at(asset_and_energy_list, 2)]
    |> Stream.filter(&(not is_nil(&1)))
    |> Enum.map(fn {asset, _value} -> asset end)
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
              value: convert_to_ceil_float(energy_consumption)
            }
          end)

    %{
      label: date |> convert_date_format(),
      dataSets: data_sets
    }
  end

  defp get_individual_segr_for_generators(date, params, prefix) do
    get_site_config_for_dashboards(params["site_id"], prefix)
    generators = convert_nil_to_list(params["generators"])

    data_sets =
          Enum.map(generators, fn asset_id ->
            %{
              name: AssetConfig.get_equipment!(asset_id, prefix).name,
              value: convert_to_ceil_float(get_segr_for_asset(date, asset_id, prefix))
            }
          end)

    %{
      label: date |> convert_date_format(),
      dataSets: data_sets
    }

  end

  defp get_segr_for_asset(date, asset_id, prefix) do
    energy_consumption = NumericalData.get_energy_consumption_for_asset(
                          asset_id,
                          NaiveDateTime.new!(date, ~T[00:00:00]),
                          NaiveDateTime.new!(date, ~T[23:59:59]),
                          prefix)
                        |> change_nil_to_zero()

    fuel_consumption = NumericalData.get_fuel_consumption_for_asset(
                        asset_id,
                        NaiveDateTime.new!(date, ~T[00:00:00]),
                        NaiveDateTime.new!(date, ~T[23:59:59]),
                        prefix)
                      |> change_nil_to_one()

    energy_consumption / fuel_consumption
  end

  #Chart no 11
  def get_ppm_chart(params, prefix) do
    cond do
      params["location"] == 0 and params["widget_x_axis"] == "asset_categories" ->
        get_workorder_status_for_site(params, ["PRV"], :group_by_asset_category, "scheduled/completed", prefix) |> Helpers.get_top_10_data("Completed")

      params["location"] == 0 and params["widget_x_axis"] == "assets" ->
        get_workorder_status_for_site(params, ["PRV"], :group_by_asset, "scheduled/completed", prefix) |> Helpers.get_top_10_data("Completed")

      params["widget_x_axis"] == "asset_categories" and not is_nil(params["asset_category_ids"])->
        get_workorder_status_for_asset_categories(params, ["PRV"], "scheduled/completed", prefix) |> Helpers.get_top_10_data("Completed")

      params["widget_x_axis"] == "assets" and not is_nil(params["assets"]) ->
        get_workorder_status_for_assets(params, ["PRV"], "scheduled/completed", prefix) |> Helpers.get_top_10_data("Completed")

      true ->
        get_workorder_status_for_site(params, ["PRV"], :group_by_asset_category, "scheduled/completed", prefix) |> Helpers.get_top_10_data("Completed")
    end
  end

  #Chart no 12
  def get_open_workorder_chart(params, prefix) do
    cond do
      params["location"] == 0 and params["widget_x_axis"] == "asset_categories" ->
        get_workorder_status_for_site(params, ["PRV", "BRK", "TKT"], :group_by_asset_category, "open/ip", prefix) |> Helpers.get_top_10_data("Workorders")

      params["location"] == 0 and params["widget_x_axis"] == "assets" ->
        get_workorder_status_for_site(params, ["PRV", "BRK", "TKT"], :group_by_asset, "open/ip", prefix) |> Helpers.get_top_10_data("Workorders")

      params["widget_x_axis"] == "asset_categories" and not is_nil(params["asset_category_ids"])->
        get_workorder_status_for_asset_categories(params, ["PRV", "BRK", "TKT"], "open/ip", prefix) |> Helpers.get_top_10_data("Workorders")

      params["widget_x_axis"] == "assets" and not is_nil(params["assets"]) ->
        get_workorder_status_for_assets(params, ["PRV", "BRK", "TKT"], "open/ip", prefix) |> Helpers.get_top_10_data("Workorders")

      true ->
        get_workorder_status_for_site(params, ["PRV", "BRK", "TKT"], :group_by_asset_category, "open/ip", prefix) |> Helpers.get_top_10_data("Workorders")
    end
  end

  #Chart no 13
  def get_ticket_open_status_chart(params, prefix) do
    {from_date_time, to_date_time} =
        get_site_date_time(params["from_date"], params["to_date"], params["site_id"], prefix)

    NumericalData.get_work_requests(params["site_id"], params, from_date_time, to_date_time, ["CL"], "not", prefix)
    |> group_by_ticket_category("open/ip/ticket") |> Helpers.get_top_10_data("Open")
  end

  #Chart no 14
  def get_ticket_workorder_status_chart(params, prefix) do
    cond do
      params["location"] == 0 and params["widget_x_axis"] == "asset_categories" ->
        get_workorder_status_for_site(params, ["TKT"],  :group_by_asset_category, "workorder_status", prefix) |> Helpers.get_top_10_data("Open")

      params["location"] == 0 and params["widget_x_axis"] == "assets" ->
        get_workorder_status_for_site(params, ["TKT"],  :group_by_asset, "workorder_status", prefix) |> Helpers.get_top_10_data("Open")

      params["widget_x_axis"] == "asset_categories" and not is_nil(params["asset_category_ids"])->
        get_workorder_status_for_asset_categories(params, ["TKT"], "workorder_status", prefix) |> Helpers.get_top_10_data("Open")

      params["widget_x_axis"] == "assets" and not is_nil(params["assets"]) ->
        get_workorder_status_for_assets(params, ["TKT"], "workorder_status", prefix) |> Helpers.get_top_10_data("Open")

      true ->
        get_workorder_status_for_site(params, ["TKT"],  :group_by_asset_category, "workorder_status", prefix) |> Helpers.get_top_10_data("Open")
    end
  end

  #Chart no 15
  def get_breakdown_workorder_status_chart(params, prefix) do
    cond do
      params["location"] == 0 and params["widget_x_axis"] == "asset_categories" ->
        get_workorder_status_for_site(params, ["BRK"], :group_by_asset_category, "workorder_status", prefix) |> Helpers.get_top_10_data("Open")

      params["location"] == 0 and params["widget_x_axis"] == "assets" ->
        get_workorder_status_for_site(params, ["BRK"], :group_by_asset, "workorder_status", prefix) |> Helpers.get_top_10_data("Open")

      params["widget_x_axis"] == "asset_categories" and not is_nil(params["asset_category_ids"])->
        get_workorder_status_for_asset_categories(params, ["BRK"], "workorder_status", prefix) |> Helpers.get_top_10_data("Open")

      params["widget_x_axis"] == "assets" and not is_nil(params["assets"]) ->
        get_workorder_status_for_asset_categories(params, ["BRK"], "workorder_status", prefix) |> Helpers.get_top_10_data("Open")

      true ->
        get_workorder_status_for_site(params, ["BRK"], :group_by_asset_category, "workorder_status", prefix) |> Helpers.get_top_10_data("Open")
    end
  end

  #Chart no 16
  def get_equipment_under_maintenance_chart(params, prefix) do
    site_dt = get_site_date_time_now(params["site_id"], prefix)

    NumericalData.get_equipment_with_status("OFF", params, prefix)
    |> Enum.map(fn equipment ->
        %{
          label: equipment.name,
          dataSets: [
              %{
                  name: "Ageing",
                  value: convert_to_ceil_float(NumericalData.get_equipment_ageing(equipment, site_dt, prefix))
              }
          ]
      }
      end)
  end

  #Chart no 17
  def get_mtbf_chart(params, prefix) do
    cond do
      not is_nil(params["asset_category_ids"]) and params["asset_category_ids"] != [] ->
        get_mtbf_or_mttr_for_asset_categories(params, "MTBF", :get_mtbf_of_equipment, prefix)

      not is_nil(params["asset_ids"]) and params["asset_ids"] != [] ->
        get_mtbf_or_mttr_for_assets(params, "MTBF", :get_mtbf_of_equipment, prefix)

      true ->
        get_mtbf_or_mttr_for_assets(Map.put(params, "asset_ids", []), "MTBF", :get_mtbf_of_equipment, prefix)

    end
  end

  #Chart no 18
  def get_mttr_chart(params, prefix) do
    cond do
      not is_nil(params["asset_category_ids"]) and params["asset_category_ids"] != [] ->
        get_mtbf_or_mttr_for_asset_categories(params, "MTTR", :get_mttr_of_equipment, prefix)

      not is_nil(params["asset_ids"]) and params["asset_ids"] != [] ->
        get_mtbf_or_mttr_for_assets(params, "MTTR", :get_mttr_of_equipment, prefix)

      true ->
        get_mtbf_or_mttr_for_assets(Map.put(params, "asset_ids", []), "MTTR", :get_mttr_of_equipment, prefix)

    end
  end

  #Chart no 19
  def get_intime_reporting_chart(params, prefix) do
    site_id = params["site_id"]
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], site_id, prefix)
    shift_tuples = Helpers.get_shifts_tuple(params["shift_ids"], site_id, prefix)
    Helpers.get_org_units_tuple(params["org_unit_ids"], prefix)
    |> Enum.map(&Task.async(fn ->
                              get_intime_reporting_for_org_unit(site_id, &1, shift_tuples,  from_date, to_date, prefix)
                            end))
    |> Task.await_many()
  end

  defp get_intime_reporting_for_org_unit(site_id, {org_unit_name, org_unit_id}, shift_tuples,  from_date, to_date, prefix) do
    datasets =
      shift_tuples
      |> Enum.map(fn {shift_name, shift_id} -> get_intime_reporting_percentage(site_id, org_unit_id, {shift_name, shift_id}, from_date, to_date, prefix) end)

    %{
      label: org_unit_name,
      dataSets: datasets
    }
  end

  defp get_intime_reporting_percentage(site_id, org_unit_id, {shift_name, shift_id}, from_date, to_date, prefix) do
    expected_rosters = NumericalData.get_expected_rosters(site_id, org_unit_id, shift_id, from_date, to_date, prefix) |> Enum.count() |> change_nil_to_one()
    actual_attendances =
      NumericalData.get_attendances(site_id, org_unit_id, shift_id, NaiveDateTime.new!(from_date, ~T[00:00:00]), NaiveDateTime.new!(to_date, ~T[23:59:59]), prefix)
      |> Stream.filter(fn att ->
          Time.compare(NaiveDateTime.to_time(att.in_time), att.shift_start) != :gt
        end)
      |> Enum.count()

    %{
      name: shift_name,
      count: actual_attendances,
      value: convert_to_ceil_float(calculate_percentage(actual_attendances, expected_rosters))
    }
  end

  #Chart no 20
  def get_shift_coverage_chart(params, prefix) do
    site_id = params["site_id"]
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], site_id, prefix)
    shift_tuples = Helpers.get_shifts_tuple(params["shift_ids"], site_id, prefix)
    Helpers.get_org_units_tuple(params["org_unit_ids"], prefix)
    |> Enum.map(&Task.async(fn ->
                              get_shift_coverage_for_org_unit(site_id, &1, shift_tuples,  from_date, to_date, prefix)
                            end))
    |> Task.await_many()
  end

  defp get_shift_coverage_for_org_unit(site_id, {org_unit_name, org_unit_id}, shift_tuples,  from_date, to_date, prefix) do
    datasets =
      shift_tuples
      |> Enum.map(fn {shift_name, shift_id} -> get_shift_coverage_percentage(site_id, org_unit_id, {shift_name, shift_id}, from_date, to_date, prefix) end)

    %{
      label: org_unit_name,
      dataSets: datasets
    }
  end

  defp get_shift_coverage_percentage(site_id, org_unit_id, {shift_name, shift_id}, from_date, to_date, prefix) do
    expected_rosters = NumericalData.get_expected_rosters(site_id, org_unit_id, shift_id, from_date, to_date, prefix) |> Enum.count() |> change_nil_to_one()
    actual_attendances = NumericalData.get_attendances(site_id, org_unit_id, shift_id, NaiveDateTime.new!(from_date, ~T[00:00:00]), NaiveDateTime.new!(to_date, ~T[23:59:59]), prefix) |> Enum.count()

    %{
      name: shift_name,
      count: actual_attendances,
      value: convert_to_ceil_float(calculate_percentage(actual_attendances, expected_rosters))
    }
  end

  defp get_workorder_status_for_site(params, types, :group_by_asset_category, organize_for, prefix) do
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)
    NumericalData.get_workorder_chart_data_for_site_asset_category(
            params["site_id"],
            from_date,
            to_date,
            types,
            params["criticality"],
            prefix) |> group_by_asset_category(organize_for)
  end

  defp get_workorder_status_for_site(params, types, :group_by_asset, organize_for, prefix) do
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    location_workorders =
      NumericalData.get_workorder_chart_data_for_site_asset(
        params["site_id"],
        from_date,
        to_date,
        "L",
        types,
        params["criticality"],
        prefix) |> group_by_asset(organize_for, "L", prefix)

    equipment_workorders =
      NumericalData.get_workorder_chart_data_for_site_asset(
        params["site_id"],
        from_date,
        to_date,
        "E",
        types,
        params["criticality"],
        prefix) |> group_by_asset(organize_for, "E", prefix)

    location_workorders ++ equipment_workorders
  end

  defp get_workorder_status_for_asset_categories(params, types, organize_for, prefix) do
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)
    NumericalData.get_workorder_chart_data_for_asset_categories(
        params["site_id"],
        from_date,
        to_date,
        params["asset_category_ids"],
        types,
        params["criticality"],
        prefix) |> group_by_asset_category(organize_for)
  end

  defp get_workorder_status_for_assets(params, types, organize_for, prefix) do
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)
    location_ids = Stream.filter(params["assets"], fn obj ->  obj["type"] == "L" end) |> Enum.map(fn l -> l["id"] end)
    equipment_ids = Stream.filter(params["assets"], fn obj ->  obj["type"] == "E" end) |> Enum.map(fn e -> e["id"] end)
    location_workorders =
      NumericalData.get_workorder_chart_data_for_assets(
        params["site_id"],
        from_date,
        to_date,
        location_ids,
        "L",
        types,
        params["criticality"],
        prefix) |> group_by_asset(organize_for, "L", prefix)

    equipment_workorders =
      NumericalData.get_workorder_chart_data_for_assets(
        params["site_id"],
        from_date,
        to_date,
        equipment_ids,
        "E",
        types,
        params["criticality"],
        prefix) |> group_by_asset(organize_for, "E", prefix)

    location_workorders ++ equipment_workorders
  end

  defp group_by_asset(work_orders, organize_for, asset_type, prefix) do
    Enum.group_by(work_orders, &(&1.asset_id))
    |> Enum.map(fn {asset_id, info} ->
          wo_list = Enum.map(info, fn i -> i.work_order end)
          %{
            label: List.first(info).asset_name,
            dataSets: calculate_datasets(wo_list, organize_for)
          }
      end)
  end

  defp group_by_asset_category(work_orders, organize_for) do
    Enum.group_by(work_orders, &(&1.asset_category_id))
    |> Enum.map(fn {_asset_id, info} ->
          wo_list = Enum.map(info, fn i -> i.work_order end)
          %{
            label: List.first(info).asset_category_name,
            dataSets: calculate_datasets(wo_list, organize_for)
          }
      end)
  end

  def group_by_ticket_category(work_requests, organize_for) do
    Enum.group_by(work_requests, &(&1.workrequest_category_id))
    |> Enum.map(fn { _asset_category_id, tickets } ->
        %{
          label: List.first(tickets).workrequest_category.name,
          dataSets: calculate_datasets(tickets, organize_for)
        }
    end)
  end

  defp calculate_datasets(work_orders, "workorder_status") do
    open = Stream.reject(work_orders, &(is_nil(&1))) |> Enum.count(fn wo -> wo.status in @open_workorders end)
    completed = Stream.reject(work_orders, &(is_nil(&1))) |> Enum.count(fn wo -> wo.status in @completed_workorders end)
    in_progress = Stream.reject(work_orders, &(is_nil(&1))) |> Enum.count(fn wo -> wo.status not in @open_workorders ++ @completed_workorders end)
    total = open + completed + in_progress
    [
      %{
        name: "Open",
        value: open,
        hover_value: calculate_percentage(open, total)
      },
      %{
        name: "Completed",
        value: completed,
        hover_value: calculate_percentage(completed, total)
      },
      %{
        name: "In Progress",
        value: in_progress,
        hover_value: calculate_percentage(in_progress, total)
      }
    ]
  end

  defp calculate_datasets(work_orders, "scheduled/completed") do
    completed_count = Stream.reject(work_orders, &(is_nil(&1))) |> Enum.count(fn wo -> wo.status in @completed_workorders end)
    incomplete_count = Stream.reject(work_orders, &(is_nil(&1))) |> Enum.count(fn wo -> wo.status not in @completed_workorders end)
    total_count = Stream.reject(work_orders, &(is_nil(&1))) |> Enum.count() |> change_nil_to_one()

    [
      %{
        name: "Not Completed",
        hover_value: incomplete_count,
        value: calculate_percentage(incomplete_count, total_count)
      },
      %{
        name: "Completed",
        hover_value: completed_count,
        value: calculate_percentage(completed_count, total_count)
      }
    ]
  end

  defp calculate_datasets(work_orders, "open/ip") do
    inprogress_count = Stream.reject(work_orders, &(is_nil(&1))) |> Enum.count(fn wo -> wo.status not in @open_workorders ++ @completed_workorders end)
    total_count = Stream.reject(work_orders, &(is_nil(&1))) |> Enum.count(fn wo -> wo.status not in @completed_workorders end) |> change_nil_to_one()

    [
      %{
        name: "Workorders",
        hover_value: inprogress_count,
        value: calculate_percentage(inprogress_count, total_count)
      }
    ]
  end

  defp calculate_datasets(work_requests, "open/ip/ticket") do
    open = Stream.filter(work_requests, fn wr -> wr.status in ["RS", "ROP"] end) |> Enum.count()
    in_progress = Stream.filter(work_requests, fn wr -> wr.status not in ["RS", "ROP", "CP"] end) |> Enum.count()
    completed = Stream.filter(work_requests, fn wr -> wr.status in ["CP"] end) |> Enum.count()
    total = open + in_progress + completed
    [
      %{
        name: "Open",
        value: open,
        hover_value: calculate_percentage(open, total)
      },
      %{
        name: "In Progress",
        value: in_progress,
        hover_value: calculate_percentage(in_progress, total)
      },
      %{
        name: "Completed",
        value: completed,
        hover_value: calculate_percentage(completed, total)
      }
    ]
  end

  defp get_mtbf_or_mttr_for_asset_categories(params, label, query_func, prefix) do
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    Enum.map(params["asset_category_ids"], fn ac_id ->
      get_mtbf_or_mttr_for_asset_category(
        ac_id,
        NaiveDateTime.new!(from_date, ~T[00:00:00]),
        NaiveDateTime.new!(to_date, ~T[23:59:59]),
        label,
        query_func,
        prefix
      )
    end)
  end

  defp get_mtbf_or_mttr_for_assets(params, label, query_func, prefix) do
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    Enum.map(params["asset_ids"], fn asset_id ->
      get_mtbf_or_mttr_for_individual_asset(
        AssetConfig.get_equipment!(asset_id, prefix),
        NaiveDateTime.new!(from_date, ~T[00:00:00]),
        NaiveDateTime.new!(to_date, ~T[23:59:59]),
        label,
        query_func,
        prefix)
    end)
  end

  defp get_mtbf_or_mttr_for_asset_category(asset_category_id, from_dt, to_dt, label, query_func, prefix) do
    mtbf =
      AssetConfig.get_assets_by_asset_category_id(asset_category_id, prefix)
      |> Stream.map(fn asset -> get_mtbf_or_mttr_tuple_for_asset(asset, from_dt, to_dt, query_func, prefix) end)
      |> Stream.map(fn {_k, v} -> v end)
      |> Enum.sum()
      |> convert_to_float()

    %{
      label: AssetConfig.get_asset_category!(asset_category_id, prefix).name,
      dataSets: [
          %{
              name: label,
              value: Float.ceil(mtbf, 2),
              displayValue: convert_to_hours_and_minutes(mtbf)
          }
      ]
    }
  end


  defp get_mtbf_or_mttr_for_individual_asset(asset, from_dt, to_dt, label, query_func, prefix) do
    {asset_name, mtbf} = get_mtbf_or_mttr_tuple_for_asset(asset, from_dt, to_dt, query_func, prefix)
      %{
        label: asset_name,
        dataSets: [
            %{
                name: label,
                value: Float.ceil(mtbf/1, 2),
                displayValue: convert_to_hours_and_minutes(mtbf)
            }
        ]
      }

  end

  defp get_mtbf_or_mttr_tuple_for_asset(asset, from_dt, to_dt, query_func, prefix) do
    mtbf = apply(NumericalData, query_func, [asset.id, from_dt, to_dt, prefix])
    {asset.name, mtbf}
  end

  #Chart no 22
  def get_inventory_breach_data(params, prefix) do
    NumericalData.get_number_of_days_breached(params, prefix)
   |> Enum.group_by(&(&1.inventory_item_id))
   |> process_breach_entries(prefix)
  end


  defp process_breach_entries(entries, prefix) do
    Enum.map(entries, fn {k, v} ->
      %{
        label: InventoryManagement.get_inventory_item!(k, prefix).name,
        dataSets: [
          %{
            name: "Days",
            value: convert_to_ceil_float(process_breach_date_list(v)) |> change_nil_to_zero()
          }
        ]
      }
    end)
  end

  #Chart no 21
  def get_work_order_cost_data(params, prefix) do
    NumericalData.get_work_order_cost(params, prefix)
    |> Enum.group_by(&(&1.scheduled_date))
    |> Enum.map(fn {k, v} ->
      %{
        label: k,
        dataSets: process_wo_for_date(v, params["asset_type"], prefix)
      }
    end)
  end

  defp process_breach_date_list(breach_data) do
    Enum.sort_by(breach_data, &(&1.breached_date_time), NaiveDateTime)
    |> Enum.filter(fn x -> x.is_msl_breached == "YES" end)
    |> List.first()
  end

  defp process_wo_for_date(work_orders, nil, prefix) do
    process_wo_for_date(work_orders, "L", prefix) ++ process_wo_for_date(work_orders, "E", prefix)
  end

  defp process_wo_for_date(work_orders, asset_type, prefix) do
    Enum.group_by(work_orders, &(&1.asset_id))
    |> Enum.map(fn {k, v} ->
      %{
        name: get_asset(k, asset_type, prefix).name,
        value: Enum.map(v, fn v -> v.cost end) |> Enum.sum()
      }
    end)
  end

  defp get_asset(asset_id, "E", prefix), do: AssetConfig.get_equipment!(asset_id, prefix)
  defp get_asset(asset_id, "L", prefix), do: AssetConfig.get_location!(asset_id, prefix)

end
