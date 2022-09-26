defmodule Inconn2Service.Dashboards.NumericalChart do

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Dashboards.{NumericalData, Helpers}
  alias Inconn2Service.DashboardConfiguration
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Dashboards.NumericalData

  def get_numerical_charts_for_24_hours(site_id, device, user, prefix) do

    config = get_site_config_for_dashboards(site_id, prefix)

    energy_consumption =
      get_energy_consumption_for_24_hours(site_id, config, prefix)
      |> change_nil_to_zero()

    water_consumption =
      get_water_consumption_for_24_hours(site_id, config, prefix)
      |> change_nil_to_zero()

    fuel_consumption =
      get_fuel_consumption_for_24_hours(site_id, config, prefix)
      |> change_nil_to_zero()

    DashboardConfiguration.list_user_widget_configs_for_user(user.id, device, prefix)
    |> Stream.map(&Task.async(fn -> get_individual_data(&1, energy_consumption, water_consumption, fuel_consumption, config, site_id, prefix) end))
    |> Enum.map(&Task.await/1)

  end

  defp get_individual_data(widget_config, energy_consumption, water_consumption, fuel_consumption, config, site_id, prefix) do
    func = match_widget_codes()[widget_config.widget_code]
    args = match_arguments(widget_config.widget_code, energy_consumption, water_consumption, fuel_consumption, config, site_id, prefix)
    case func do
      nil ->
        %{}
      _ ->
        apply(__MODULE__, func, args)
        |> Map.put(:position, widget_config.position)
    end

  end

  defp match_widget_codes() do
    %{
      "ENCON" => :energy_consumption_data,
      "ENCOS" => :energy_cost_data,
      "ENPEI" => :epi_data,
      "ENTOP" => :top_three_data,
      "WACON" => :water_consumption_data,
      "WACOS" => :water_cost_data,
      "FUCON" => :fuel_consumption_data,
      "FUCOS" => :fuel_cost_data,
      "ENSUB" => :sub_meters_data,
      "SEGRE" => :segr_data,
      "PPMCW" => :ppm_data,
      "OPWOR" => :workorder_status_data,
      "OPTIC" => :ticket_status_data,
      "SEWOR" => :service_workorder_data,
      "BRWOR" => :breakdown_workorder_data,
      "EQUMN" => :euipment_under_maintenance_data,
      "MTBFA" => :mtbf_data,
      "MTTRA" => :mttr_data
    }
  end

  defp match_arguments(code, energy_consumption, water_consumption, fuel_consumption, config, site_id, prefix) do
    case code do
      "ENCON" -> [energy_consumption]
      "ENCOS" -> [energy_consumption, change_nil_to_zero(config["energy_cost_per_unit"])]
      "ENPEI" -> [energy_consumption, change_nil_to_one(config["area"])]
      "ENTOP" -> [site_id, config, prefix]
      "WACON" -> [water_consumption]
      "WACOS" -> [water_consumption, change_nil_to_zero(config["water_cost_per_unit"])]
      "FUCON" -> [fuel_consumption]
      "FUCOS" -> [fuel_consumption, change_nil_to_zero(config["fuel_cost_per_unit"])]
      "ENSUB" -> [site_id, config, prefix]
      "SEGRE" -> [site_id, config, prefix]
      _ -> [site_id, prefix]
    end
  end

  def energy_consumption_data(energy_consumption) do
    %{
      id: 1,
      key: "ENCON",
      name: "Energy Consumption",
      displayTxt: energy_consumption,
      unit: "kWh",
      type: 1
    }
  end

  def energy_cost_data(energy_consumption, cost_per_unit) do
    %{
      id: 2,
      key: "ENCOS",
      name: "Energy Cost",
      displayTxt: energy_consumption * cost_per_unit,
      unit: "INR",
      type: 1
    }
  end

  def epi_data(energy_consumption, area) do
    %{
      id: 3,
      key: "ENPEI",
      name: "Energy performance Indicator (EPI)",
      displayTxt: energy_consumption / area,
      unit: "kWh/sqft",
      type: 1
    }
  end

  def top_three_data(site_id, config, prefix) do
    %{
      id: 4,
      key: "ENTOP",
      name: "Top 3 non main meter consumption",
      unit: "kWh",
      type: 2,
      tableInfo: %{
          headers: ["Name", "Consumption ( kWh )"],
          list: get_top_three_consumers_for_24_hours(site_id, config, prefix)
      }
    }
  end

  def water_consumption_data(water_consumption) do
    %{
      id: 5,
      key: "WACON",
      name: "Water Consumption",
      displayTxt: water_consumption,
      unit: "kilo ltrs",
      type: 1
    }
  end

  def water_cost_data(water_consumption, cost_per_unit) do
    %{
      id: 6,
      key: "WACOS",
      name: "Water Cost",
      displayTxt: water_consumption * cost_per_unit,
      unit: "INR",
      type: 1
    }
  end

  def fuel_consumption_data(fuel_consumption) do
    %{
      id: 7,
      key: "FUCON",
      name: "Fuel Consumption",
      displayTxt: fuel_consumption,
      unit: "ltrs",
      type: 1
    }
  end

  def fuel_cost_data(fuel_consumption, cost_per_unit) do
    %{
      id: 8,
      key: "FUCOS",
      name: "Fuel Cost",
      displayTxt: fuel_consumption * cost_per_unit,
      unit: "INR",
      type: 1
    }
  end

  def sub_meters_data(site_id, config, prefix) do
    %{
      id: 9,
      key: "ENSUB",
      name: "Sub meters - Consumption",
      unit: "kWh",
      type: 2,
      tableInfo: %{
          headers: ["Name", "Consumption ( kWh )"],
          list: get_energy_of_sub_meters_for_24_hours(site_id, config, prefix)
      }
    }
  end

  def segr_data(site_id, config, prefix) do
    %{
      id: 10,
      key: "SEGRE",
      name: "SEGR",
      unit: "kwhr/litr",
      type: 1,
      displayTxt: get_segr_for_24_hours(site_id, config, prefix)
    }
  end

  def ppm_data(site_id, prefix) do
    %{
      id: 11,
      key: "PPMCW",
      name: "PPM Compliance",
      unit: "%",
      type: 1,
      displayTxt: get_ppm_compliance(site_id, prefix)
    }
  end

  def workorder_status_data(site_id, prefix) do
    %{
      id: 12,
      key: "OPWOR",
      name: "Open/in-progress Workorder status",
      unit: "%",
      type: 1,
      displayTxt: get_open_workorder_status(site_id, prefix),
    }
  end

  def ticket_status_data(site_id, prefix) do
    %{
      id: 13,
      key: "OPTIC",
      name: "Open/in-progress Ticket status",
      unit: "Tickets",
      type: 1,
      displayTxt: get_open_ticket_status(site_id, prefix),
    }
  end

  def service_workorder_data(site_id, prefix) do
    %{
      id: 14,
      key: "SEWOR",
      name: "Service Workorder Status",
      unit: "%",
      type: 3,
      chartResp: get_ticket_workorder_status_chart(site_id, prefix),
    }
  end

  def breakdown_workorder_data(site_id, prefix) do
    %{
      id: 15,
      key: "BRWOR",
      name: "Breakdown work Status – YTD",
      unit: "WorkOrders",
      type: 1,
      displayTxt: get_breakdown_workorder_status_shcart(site_id, prefix)
    }
  end

  def euipment_under_maintenance_data(site_id, prefix) do
    %{
      id: 16,
      key: "EQUMN",
      name: "Equipment under maintenance at present",
      unit: "assets",
      type: 1,
      displayTxt: get_equipment_under_maintenance(site_id, prefix)
   }
  end

  def mtbf_data(site_id, prefix) do
    %{
      id: 17,
      key: "MTBFA",
      name: "Mean time between failures",
      unit: "YTD",
      type: 1,
      displayTxt: get_mtbf(site_id, prefix)
    }
  end

  def mttr_data(site_id, prefix) do
    %{
      id: 18,
      key: "MTTRA",
      name: "Mean time to recovery",
      unit: "YTD",
      type: 1,
      displayTxt: get_mttr(site_id, prefix)
    }
  end

  def get_energy_consumption_for_24_hours(site_id, config, prefix) do
    to_dt = get_site_date_time_now(site_id, prefix)
    from_dt = NaiveDateTime.add(to_dt, -86400)
    NumericalData.get_energy_consumption_for_assets(config["energy_main_meters"], from_dt, to_dt, prefix)
  end

  def get_water_consumption_for_24_hours(site_id, config, prefix) do
    to_dt = get_site_date_time_now(site_id, prefix)
    from_dt = NaiveDateTime.add(to_dt, -86400)
    NumericalData.get_water_consumption_for_assets(config["water_main_meters"], from_dt, to_dt, prefix)
  end

  def get_fuel_consumption_for_24_hours(site_id, config, prefix) do
    to_dt = get_site_date_time_now(site_id, prefix)
    from_dt = NaiveDateTime.add(to_dt, -86400)
    NumericalData.get_fuel_consumption_for_assets(config["fuel_main_meters"], from_dt, to_dt, prefix)
  end

  def get_top_three_consumers_for_24_hours(site_id, config, prefix) do
    to_dt = get_site_date_time_now(site_id, prefix)
    from_dt = NaiveDateTime.add(to_dt, -86400)

    energy_meters = Helpers.get_sub_meter_assets(config, "E", prefix)

    asset_and_energy_list = Helpers.get_assets_and_energy_list(energy_meters, from_dt, to_dt, prefix)

    [Enum.at(asset_and_energy_list, 0), Enum.at(asset_and_energy_list, 1), Enum.at(asset_and_energy_list, 2)]
    |> Stream.filter(&(not is_nil(&1)))
    |> Enum.map(fn {asset, value} -> %{name: asset.name, val: value} end)
  end

  def get_energy_of_sub_meters_for_24_hours(site_id, config, prefix) do
    to_dt = get_site_date_time_now(site_id, prefix)
    from_dt = NaiveDateTime.add(to_dt, -86400)

    energy_meters = Helpers.get_sub_meter_assets(config, "E", prefix)

    asset_and_energy_list = Helpers.get_assets_and_energy_list(energy_meters, from_dt, to_dt, prefix)

    asset_and_energy_list
    |> Stream.filter(&(not is_nil(&1)))
    |> Enum.map(fn {asset, value} -> %{name: asset.name, val: value} end)
  end

  def get_segr_for_24_hours(site_id, config, prefix) do
    to_dt = get_site_date_time_now(site_id, prefix)
    from_dt = NaiveDateTime.add(to_dt, -86400)

    generators = config["generators"]

    energy_consumption = NumericalData.get_energy_consumption_for_assets(generators, from_dt, to_dt, prefix)
                        |> change_nil_to_zero()

    fuel_consumption = NumericalData.get_fuel_consumption_for_assets(generators, from_dt, to_dt, prefix)
                      |> change_nil_to_one()

    calculate_percentage(energy_consumption, fuel_consumption)
  end

  def get_ppm_compliance(site_id, prefix) do
    {from_date, to_date} = get_month_date_till_now(site_id, prefix)

    scheduled_wo = NumericalData.get_workorder_for_chart(site_id, from_date, to_date, [], nil, "PRV", prefix) |> Enum.count() |> change_nil_to_one()
    completed_wo = NumericalData.get_workorder_for_chart(site_id, from_date, to_date, ["cp"], "in", "PRV", prefix) |> Enum.count()

    calculate_percentage(completed_wo, scheduled_wo)
  end

  def get_open_workorder_status(site_id, prefix) do
    {from_date, to_date} = get_month_date_till_now(site_id, prefix)

    open_wo = NumericalData.get_workorder_for_chart(site_id, from_date, to_date, ["cp", "cn"], "not", nil, prefix) |> Enum.count() |> change_nil_to_one()
    inprogress_wo = NumericalData.get_workorder_for_chart(site_id, from_date, to_date, ["cr", "as", "cp", "cn"], "not", nil, prefix) |> Enum.count()

    calculate_percentage(inprogress_wo, open_wo)
  end

  def get_open_ticket_status(site_id, prefix) do
    {from_datetime, to_datetime} = get_month_date_time_till_now(site_id, prefix)
    NumericalData.get_work_requests(site_id, from_datetime, to_datetime, ["CL", "CP", "RJ", "CS"], "not", prefix)
    |> Enum.count()
  end

  def get_ticket_workorder_status_chart(site_id, prefix) do
    {from_date, to_date} = get_month_date_till_now(site_id, prefix)

    total_wo = NumericalData.get_workorder_for_chart(site_id, from_date, to_date, [], nil, "TKT", prefix)
    total_count = total_wo |> length() |> change_nil_to_one()
    open_count = Enum.count(total_wo, fn wo -> wo.status in ["cr", "as"] end)
    completed_count = Enum.count(total_wo, fn wo -> wo.status == "cp" end)
    inprogress_count = Enum.count(total_wo, fn wo -> wo.status not in ["cr", "as", "cp",] end)

    [
      %{
        label: "Open",
        value: calculate_percentage(open_count, total_count),
        color: "#ff0000"
      },
      %{
        label: "In Progress",
        value: calculate_percentage(inprogress_count, total_count),
        color: "#00ff00"
      },
      %{
        label: "Closed",
        value: calculate_percentage(completed_count, total_count),
        color: "#ffbf00"
      }
    ]
  end

  def get_breakdown_workorder_status_shcart(site_id, prefix) do
    {from_date, to_date} = get_month_date_till_now(site_id, prefix)
    NumericalData.get_workorder_for_chart(site_id, from_date, to_date, [], nil, "BRK", prefix)
    |> length()
  end

  def get_equipment_under_maintenance(site_id, prefix) do
    NumericalData.get_equipment_with_status("OFF", %{"site_id" => site_id}, prefix)
    |> length()
  end

  def get_mtbf(site_id, prefix) do
    {from_dt, to_dt} = get_yesterday_date_time(site_id, prefix)
    AssetConfig.list_equipments(site_id, prefix)
    |> Stream.map(&Task.async(fn -> NumericalData.get_mtbf_of_equipment(&1.id, from_dt, to_dt, prefix) end))
    |> Stream.map(&Task.await/1)
    |> Enum.sum()
  end

  def get_mttr(site_id, prefix) do
    {from_dt, to_dt} = get_yesterday_date_time(site_id, prefix)
    AssetConfig.list_equipments(site_id, prefix)
    |> Stream.map(&Task.async(fn -> NumericalData.get_mttr_of_equipment(&1.id, from_dt, to_dt, prefix) end))
    |> Stream.map(&Task.await/1)
    |> Enum.sum()
  end

  def get_ppm_plan(site_id, prefix) do
    date = get_site_date_now(site_id, prefix)
    NumericalData.get_schedules_for_today(site_id, date, prefix)
    |> Inconn2Service.Report.get_calculated_dates_for_schedules(date, date, [], prefix)
    |> Enum.map(fn {_k, v} -> length(v) end)
    |> List.first()
    |> change_nil_to_zero()
  end

  def breached_items(site_id, prefix) do
    NumericalData.breached_items_conut_for_site(site_id, prefix)
  end


  defp all_widgets() do
    [
      %{widget_code: "ENCON", position: 1 },
      %{widget_code: "ENCOS", position: 2 },
      %{widget_code: "ENPEI", position: 3 },
      %{widget_code: "ENTOP", position: 4 },
      %{widget_code: "WACON", position: 5 },
      %{widget_code: "WACOS", position: 6 },
      %{widget_code: "FUCON", position: 7 },
      %{widget_code: "FUCOS", position: 8 },
      %{widget_code: "ENSUB", position: 9 },
      %{widget_code: "SEGRE", position: 10 },
      %{widget_code: "PPMCW", position: 11 },
      %{widget_code: "OPWOR", position: 12 },
      %{widget_code: "OPTIC", position: 13 },
      %{widget_code: "SEWOR", position: 14 },
      %{widget_code: "BRWOR", position: 15 },
      %{widget_code: "EQUMN", position: 16 },
      %{widget_code: "MTBFA", position: 17 },
      %{widget_code: "MTTRA", position: 18 }
      ]
  end

end
