defmodule Inconn2Service.Dashboards.DashboardCharts do

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Dashboards.{NumericalData, Helpers}
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.InventoryManagement

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

    config = get_site_config_for_dashboards(params["site_id"], prefix)

    assets = Helpers.get_sub_meter_assets(config, "E", prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_energy_consumption_for_assets(&1, assets, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  def get_segr_for_generators(params, prefix) do
    date_list = form_date_list_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)

    date_list
    |> Enum.map(&Task.async(fn -> get_individual_segr_for_generators(&1, params, prefix) end))
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
              value: energy_consumption
            }
          end)

    %{
      label: date,
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
              value: get_segr_for_asset(date, asset_id, prefix)
            }
          end)

    %{
      label: date,
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

  def get_ppm_chart(params, prefix) do
    cond do
      not is_nil(params["asset_category_ids"]) ->
        get_ppms_using_asset_category_ids(params, prefix)

      not is_nil(params["asset_ids"]) ->
        get_ppms_using_assets(params, prefix)

    end
  end

  def get_open_workorder_chart(params, prefix) do
    cond do
      not is_nil(params["asset_category_ids"]) ->
        get_open_workorder_using_asset_category_ids(params, prefix)

      not is_nil(params["asset_ids"]) ->
        get_open_workorder_using_assets(params, prefix)

    end
  end

  def get_ticket_open_status_chart(params, prefix) do
    {from_date_time, to_date_time} =
        get_site_date_time(params["from_date"], params["to_date"], params["site_id"], prefix)

    NumericalData.get_work_requests(params["site_id"], params, from_date_time, to_date_time, ["CL"], "not", prefix)
    |> group_by_ticket_category("open/ip/ticket")
  end

  def get_ticket_workorder_status_chart(params, prefix) do
    cond do
      not is_nil(params["asset_category_ids"]) ->
        get_workorder_status_for_asset_categories(params, "TKT", prefix)

      not is_nil(params["asset_ids"]) ->
        get_workorder_status_for_assets(params, "TKT", prefix)

    end
  end

  def get_breakdown_workorder_status_chart(params, prefix) do
    cond do
      not is_nil(params["asset_category_ids"]) ->
        get_workorder_status_for_asset_categories(params, "BRK", prefix)

      not is_nil(params["asset_ids"]) ->
        get_workorder_status_for_assets(params, "BRK", prefix)

    end
  end

  def get_equipment_under_maintenance_chart(params, prefix) do
    site_dt = get_site_date_time_now(params["site_id"], prefix)

    NumericalData.get_equipment_with_status("OFF", params, prefix)
    |> Enum.map(fn equipment ->
        %{
          label: equipment.name,
          dataSets: [
              %{
                  name: "Ageing",
                  value: NumericalData.get_equipment_ageing(equipment, site_dt, prefix)
              }
          ]
      }
      end)
  end

  def get_mtbf_chart(params, prefix) do
    cond do
      not is_nil(params["asset_category_ids"]) ->
        get_mtbf_or_mttr_for_asset_categories(params, "MTBF", :get_mtbf_of_equipment, prefix)

      not is_nil(params["asset_ids"]) ->
        get_mtbf_or_mttr_for_assets(params, "MTBF", :get_mtbf_of_equipment, prefix)

    end
  end

  def get_mttr_chart(params, prefix) do
    cond do
      not is_nil(params["asset_category_ids"]) ->
        get_mtbf_or_mttr_for_asset_categories(params, "MTTR", :get_mttr_of_equipment, prefix)

      not is_nil(params["asset_ids"]) ->
        get_mtbf_or_mttr_for_assets(params, "MTTR", :get_mttr_of_equipment, prefix)

    end
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
        "PRV",
        prefix) |> group_by_asset_category("scheduled/completed")
  end

  defp get_ppms_using_assets(params, prefix) do
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
        "PRV",
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
        "PRV",
        prefix) |> group_by_asset("scheduled/completed", "E", prefix)

    location_workorders ++ equipment_workorders
  end

  def get_open_workorder_using_asset_category_ids(params, prefix) do
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)
      NumericalData.get_workorder_for_chart(
        params["site_id"],
        from_date,
        to_date,
        params["asset_category_ids"],
        nil,
        nil,
        ["cp", "cn"],
        "not",
        nil,
        prefix) |> group_by_asset_category("open/ip")
  end

  defp get_open_workorder_using_assets(params, prefix) do
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
        ["cp", "cn", "hl"],
        "not",
        nil,
        prefix) |> group_by_asset("open/ip", "L", prefix)

    equipment_workorders =
      NumericalData.get_workorder_for_chart(
        params["site_id"],
        from_date,
        to_date,
        nil,
        equipment_ids,
        "E",
        ["cp", "cn", "hl"],
        "not",
        nil,
        prefix) |> group_by_asset("open/ip", "E", prefix)

    location_workorders ++ equipment_workorders
  end

  defp get_workorder_status_for_asset_categories(params, type, prefix) do
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
          type,
          prefix) |> group_by_asset_category("workorder_status")
  end

  defp get_workorder_status_for_assets(params, type, prefix) do
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
        type,
        prefix) |> group_by_asset("workorder_status", "L", prefix)

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
        type,
        prefix) |> group_by_asset("workorder_status", "E", prefix)

    location_workorders ++ equipment_workorders
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

  defp calculate_datasets(work_orders, "workorder_status") do
    [
      %{
        name: "Open",
        value: Stream.filter(work_orders, fn wo -> wo.status in ["cr", "as"] end) |> Enum.count()
      },
      %{
        name: "Completed",
        value: Stream.filter(work_orders, fn wo -> wo.status == "cp" end) |> Enum.count()
      },
      %{
        name: "In Progress",
        value: Stream.filter(work_orders, fn wo -> wo.status not in ["cr", "as", "cp", "cn", "hl"] end) |> Enum.count()
      }
    ]
  end

  defp calculate_datasets(work_orders, "scheduled/completed") do
    completed_count = Stream.filter(work_orders, fn wo -> wo.status == "cp" end) |> Enum.count()
    incomplete_count = Stream.filter(work_orders, fn wo -> wo.status != "cp" end) |> Enum.count()
    total_count = Enum.count(work_orders) |> change_nil_to_one()

    [
      %{
        name: "Scheduled",
        value: (incomplete_count/total_count) * 100
      },
      %{
        name: "Completed",
        value: (completed_count/total_count) * 100
      }
    ]
  end

  defp calculate_datasets(work_orders, "open/ip") do
    inprogress_count = Enum.count(work_orders, fn wo -> wo.status not in ["cr", "as"] end)
    total_count = Enum.count(work_orders) |> change_nil_to_one()

    [
      %{
        name: "Workorders",
        value: (inprogress_count/total_count) * 100
      }
    ]
  end

  defp calculate_datasets(work_requests, "open/ip/ticket") do
    [
      %{
        name: "Open",
        value: Stream.filter(work_requests, fn wr -> wr.status in ["RS", "ROP"] end) |> Enum.count()
      },
      %{
        name: "In Progress",
        value: Stream.filter(work_requests, fn wr -> wr.status in ["AP", "AS"] end) |> Enum.count()
      },
      %{
        name: "Completed",
        value: Stream.filter(work_requests, fn wr -> wr.status in ["CP"] end) |> Enum.count()
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

    %{
      label: AssetConfig.get_asset_category!(asset_category_id, prefix).name,
      dataSets: [
          %{
              name: label,
              value: mtbf
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
                value: mtbf
            }
        ]
      }

  end

  defp get_mtbf_or_mttr_tuple_for_asset(asset, from_dt, to_dt, query_func, prefix) do
    mtbf = apply(NumericalData, query_func, [asset.id, from_dt, to_dt, prefix])
    {asset.name, mtbf}
  end

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
            value: process_breach_date_list(v) |> change_nil_to_zero()
          }
        ]
      }
    end)
  end

  defp process_breach_date_list(breach_data) do
    Enum.sort_by(breach_data, &(&1.breached_date_time), NaiveDateTime)
    |> Enum.filter(fn x -> x.is_msl_breached == "YES" end)
    |> List.first()
  end

end
