defmodule Inconn2Service.Dashboards.NumericalChart do

  @completed_workorders ["cp"]
  @open_workorders ["cr", "as", "execwa"]

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Settings
  alias Inconn2Service.Staff
  alias Inconn2Service.Dashboards.{NumericalData, Helpers}
  alias Inconn2Service.DashboardConfiguration
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Dashboards.NumericalData
  alias Inconn2Service.Dashboards.DashboardCharts

  def get_numerical_charts_for_24_hours(site_id, device, user, prefix) do

    config = get_site_config_for_dashboards(site_id, prefix)

    seven_day_end = get_site_date_now(site_id, prefix)
    seven_day_start = Date.add(seven_day_end, -7)

    energy_consumption =
      get_energy_consumption_for_24_hours(site_id, config, prefix)
      |> change_nil_to_zero()

    water_consumption =
      get_water_consumption_for_24_hours(site_id, config, prefix)
      |> change_nil_to_zero()

    fuel_consumption =
      get_fuel_consumption_for_24_hours(site_id, config, prefix)
      |> change_nil_to_zero()

    # all_widgets()
    DashboardConfiguration.list_user_widget_configs_for_user(user.id, device, prefix)
    |> Stream.map(&Task.async(fn -> get_individual_data(&1, energy_consumption, water_consumption, fuel_consumption, config, site_id, {seven_day_start, seven_day_end}, user, prefix) end))
    |> Enum.map(&Task.await/1)

  end

  def get_individual_data(widget_config, energy_consumption, water_consumption, fuel_consumption, config, site_id, seven_days_range_tuple, user, prefix) do
    func = match_widget_codes()[widget_config.widget_code]
    args = match_arguments(widget_config.widget_code, energy_consumption, water_consumption, fuel_consumption, config, site_id, widget_config, seven_days_range_tuple, user, prefix)
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
      "EQUMN" => :equipment_under_maintenance_data,
      "MTBFA" => :mtbf_data,
      "MTTRA" => :mttr_data,
      "INTRE" => :intime_reporting_data,
      "SHFCV" => :shift_coverage_data,
      "COSMN" => :cost_maintenance_data,
      "MSLBC" => :msl_breach_count_data,
      "PPMPL" => :ppm_plan_data
    }
  end

  defp match_arguments(code, energy_consumption, water_consumption, fuel_consumption, config, site_id, widget_config, seven_days_range_tuple, user, prefix) do
    case code do
      "ENCON" -> [energy_consumption, site_id, config, widget_config, seven_days_range_tuple, prefix]
      "ENCOS" -> [energy_consumption, change_nil_to_zero(config["energy_cost_per_unit"]), site_id, config, widget_config, seven_days_range_tuple, prefix]
      "ENPEI" -> [energy_consumption, change_nil_to_one(config["area_in_sqft"]), site_id, config, widget_config, seven_days_range_tuple, prefix]
      "ENTOP" -> [site_id, config, widget_config, prefix]
      "WACON" -> [water_consumption, site_id, config, widget_config, seven_days_range_tuple, prefix]
      "WACOS" -> [water_consumption, change_nil_to_zero(config["water_cost_per_unit"]), site_id, config, widget_config, seven_days_range_tuple, prefix]
      "FUCON" -> [fuel_consumption, site_id, config, widget_config, seven_days_range_tuple, prefix]
      "FUCOS" -> [fuel_consumption, change_nil_to_zero(config["fuel_cost_per_unit"]), site_id, config, widget_config, seven_days_range_tuple, prefix]
      "ENSUB" -> [site_id, config, widget_config, prefix]
      "SEGRE" -> [site_id, config, widget_config, prefix]
      "PPMCW" -> [site_id, widget_config, seven_days_range_tuple, prefix]
      "OPWOR" -> [site_id, widget_config, seven_days_range_tuple, prefix]
      "OPTIC" -> [site_id, widget_config, seven_days_range_tuple, prefix]
      "SEWOR" -> [site_id, widget_config, seven_days_range_tuple, prefix]
      "INTRE" -> [site_id, widget_config, seven_days_range_tuple, user, prefix]
      "SHFCV" -> [site_id, widget_config, seven_days_range_tuple, user, prefix]
      "COSMN" -> [site_id, widget_config, seven_days_range_tuple, prefix]
      _ -> [site_id, widget_config, prefix]
    end
  end

  def energy_consumption_data(energy_consumption, site_id, config, widget_config, seven_days_range_tuple, prefix) do
    numerical_func = fn -> convert_to_ceil_float(energy_consumption) end
    %{
      id: 1,
      key: "ENCON",
      name: "Energy Consumption",
      chart_data: get_chart_data_energy(site_id, widget_config.size, numerical_func, :get_energy_consumption, config, seven_days_range_tuple, prefix),
      unit: "kWh",
      size: widget_config.size,
      type: get_chart_type("ENCON", widget_config.size)
    }
  end

  def energy_cost_data(energy_consumption, cost_per_unit, site_id, config, widget_config, seven_days_range_tuple, prefix) do
    numerical_func = fn -> convert_to_ceil_float(energy_consumption * cost_per_unit) end
    %{
      id: 2,
      key: "ENCOS",
      name: "Energy Cost",
      chart_data: get_chart_data_energy(site_id, widget_config.size, numerical_func, :get_energy_cost, config, seven_days_range_tuple, prefix),
      unit: "INR",
      size: widget_config.size,
      type: get_chart_type("ENCOS", widget_config.size)
    }
  end

  def epi_data(energy_consumption, area, site_id, config, widget_config, seven_days_range_tuple, prefix) do
    numerical_func = fn -> convert_to_ceil_float(energy_consumption / area) end
    %{
      id: 3,
      key: "ENPEI",
      name: "Energy performance Indicator (EPI)",
      chart_data: get_chart_data_energy(site_id, widget_config.size, numerical_func, :get_energy_performance_indicator, config, seven_days_range_tuple, prefix),
      unit: "kWh/sqft",
      size: widget_config.size,
      type: get_chart_type("ENPEI", widget_config.size)
    }
  end

  def top_three_data(site_id, config, widget_config, prefix) do
    %{
      id: 4,
      key: "ENTOP",
      name: "Top 3 non main meter consumption",
      unit: "kWh",
      type: 2,
      size: widget_config.size,
      chart_data: %{
          headers: ["Name", "Consumption ( kWh )"],
          list: get_top_three_consumers_for_24_hours(site_id, config, prefix)
      }
    }
  end

  def water_consumption_data(water_consumption, site_id, config, widget_config, seven_days_range_tuple, prefix) do
    numerical_func = fn -> convert_to_ceil_float(water_consumption) end
    %{
      id: 5,
      key: "WACON",
      name: "Water Consumption",
      chart_data: get_chart_data_water(site_id, widget_config.size, numerical_func, :get_water_consumption, config, seven_days_range_tuple, prefix),
      unit: "kilo ltrs",
      size: widget_config.size,
      type: get_chart_type("WACON", widget_config.size)
    }
  end

  def water_cost_data(water_consumption, cost_per_unit, site_id, config, widget_config, seven_days_range_tuple, prefix) do
    numerical_func = fn -> convert_to_ceil_float(water_consumption * cost_per_unit) end
    %{
      id: 6,
      key: "WACOS",
      name: "Water Cost",
      chart_data: get_chart_data_water(site_id, widget_config.size, numerical_func, :get_water_cost, config, seven_days_range_tuple, prefix),
      unit: "INR",
      size: widget_config.size,
      type: get_chart_type("WACOS", widget_config.size)
    }
  end

  def fuel_consumption_data(fuel_consumption, site_id, config, widget_config, seven_days_range_tuple, prefix) do
    numerical_func = fn -> convert_to_ceil_float(fuel_consumption) end
    %{
      id: 7,
      key: "FUCON",
      name: "Fuel Consumption",
      chart_data: get_chart_data_fuel(site_id, widget_config.size, numerical_func, :get_fuel_consumption, config, seven_days_range_tuple, prefix),
      unit: "ltrs",
      size: widget_config.size,
      type: get_chart_type("FUCON", widget_config.size)
    }
  end

  def fuel_cost_data(fuel_consumption, cost_per_unit, site_id, config, widget_config, seven_days_range_tuple, prefix) do
    numerical_func = fn -> convert_to_ceil_float(fuel_consumption * cost_per_unit) end
    %{
      id: 8,
      key: "FUCOS",
      name: "Fuel Cost",
      chart_data: get_chart_data_fuel(site_id, widget_config.size, numerical_func, :get_fuel_cost, config, seven_days_range_tuple, prefix),
      unit: "INR",
      size: widget_config.size,
      type: get_chart_type("FUCOS", widget_config.size)
    }
  end

  def sub_meters_data(site_id, config, widget_config, prefix) do
    %{
      id: 9,
      key: "ENSUB",
      name: "Sub meters - Consumption",
      unit: "kWh",
      type: 2,
      size: widget_config.size,
      chart_data: %{
          headers: ["Name", "Consumption ( kWh )"],
          list: get_energy_of_sub_meters_for_24_hours(site_id, config, prefix)
      }
    }
  end

  def segr_data(site_id, config, widget_config, prefix) do
    %{
      id: 10,
      key: "SEGRE",
      name: "SEGR",
      unit: "kwhr/litr",
      type: 1,
      size: widget_config.size,
      chart_data: get_segr_for_24_hours(site_id, config, prefix) |> convert_to_ceil_float()
    }
  end

  def ppm_data(site_id, widget_config, seven_days_range_tuple, prefix) do
    numerical_func = fn -> get_ppm_compliance(site_id, prefix) end
    %{
      id: 11,
      key: "PPMCW",
      name: "PPM Compliance",
      unit: "%",
      size: widget_config.size,
      type: get_chart_type("PPMCW", widget_config.size),
      chart_data: get_chart_data_work_order_and_ticket(site_id, widget_config.size, numerical_func, :get_ppm_chart, seven_days_range_tuple, prefix)
    }
  end

  def workorder_status_data(site_id, widget_config, seven_days_range_tuple, prefix) do
    numerical_func = fn -> get_open_workorder_status(site_id, prefix) end
    %{
      id: 12,
      key: "OPWOR",
      name: "Open/in-progress Workorder status",
      unit: "%",
      size: widget_config.size,
      type: get_chart_type("OPWOR", widget_config.size),
      chart_data: get_chart_data_work_order_and_ticket(site_id, widget_config.size, numerical_func, :get_open_workorder_chart, seven_days_range_tuple, prefix)
    }
  end

  def ticket_status_data(site_id, widget_config, seven_days_range_tuple, prefix) do
    numerical_func = fn -> get_open_ticket_status(site_id, prefix) end
    %{
      id: 13,
      key: "OPTIC",
      name: "Open/in-progress Ticket status",
      unit: "Tickets",
      size: widget_config.size,
      type: get_chart_type("OPTIC", widget_config.size),
      chart_data: get_chart_data_work_order_and_ticket(site_id, widget_config.size, numerical_func, :get_ticket_open_status_chart, seven_days_range_tuple, prefix)
    }
  end

  def service_workorder_data(site_id, widget_config, seven_days_range_tuple, prefix) do
    numerical_func = fn -> get_ticket_workorder_status_chart(site_id, prefix) end
    %{
      id: 14,
      key: "SEWOR",
      name: "Service Workorder Status",
      unit: "%",
      size: widget_config.size,
      type: get_chart_type("SEWOR", widget_config.size),
      chart_data: get_chart_data_work_order_and_ticket(site_id, widget_config.size, numerical_func, :get_ticket_workorder_status_chart, seven_days_range_tuple, prefix)
    }
  end

  def breakdown_workorder_data(site_id, widget_config, prefix) do
    %{
      id: 15,
      key: "BRWOR",
      name: "Breakdown work Status – YTD",
      unit: "WorkOrders",
      type: 1,
      size: widget_config.size,
      chart_data: get_breakdown_workorder_status_shcart(site_id, prefix)
    }
  end

  def equipment_under_maintenance_data(site_id, widget_config, prefix) do
    %{
      id: 16,
      key: "EQUMN",
      name: "Equipment under maintenance at present",
      unit: "assets",
      type: 1,
      size: widget_config.size,
      chart_data: get_equipment_under_maintenance(site_id, prefix)
   }
  end

  def mtbf_data(site_id, widget_config, prefix) do
    %{
      id: 17,
      key: "MTBFA",
      name: "Mean time between failures",
      unit: "YTD",
      type: 1,
      size: widget_config.size,
      chart_data: get_mtbf(site_id, prefix)
    }
  end

  def mttr_data(site_id, widget_config, prefix) do
    %{
      id: 18,
      key: "MTTRA",
      name: "Mean time to recovery",
      unit: "YTD",
      type: 1,
      size: widget_config.size,
      chart_data: get_mttr(site_id, prefix)
    }
  end

  def intime_reporting_data(site_id, widget_config, seven_days_range_tuple, user, prefix) do
    numerical_func = fn -> get_intime_reporting(site_id, prefix) |> convert_to_ceil_float() end
    %{
      id: 19,
      key: "INTRE",
      name: "Intime Reporting",
      unit: "%",
      size: widget_config.size,
      type: get_chart_type("INTRE", widget_config.size),
      chart_data: get_chart_data_intime_and_shift(site_id, widget_config.size, numerical_func, :get_intime_reporting_chart, seven_days_range_tuple, user, prefix)
    }
  end

  def shift_coverage_data(site_id, widget_config, seven_days_range_tuple, user, prefix) do
    numerical_func = fn -> get_shift_coverage(site_id, prefix) |> convert_to_ceil_float() end
    %{
      id: 20,
      key: "SHFCV",
      name: "Shift Coverage",
      unit: "%",
      size: widget_config.size,
      type: get_chart_type("SHFCV", widget_config.size),
      chart_data: get_chart_data_intime_and_shift(site_id, widget_config.size, numerical_func, :get_shift_coverage_chart, seven_days_range_tuple, user, prefix)
    }
  end

  def cost_maintenance_data(site_id, widget_config, seven_days_range_tuple, prefix) do
    numerical_func = fn -> get_work_order_cost(site_id, prefix) end
    %{
      id: 21,
      key: "COSMN",
      name: "Cost - Maintenance",
      unit: "INR",
      size: widget_config.size,
      type: get_chart_type("COSMN", widget_config.size),
      chart_data: get_chart_data_workorder_cost(site_id, widget_config.size, numerical_func, :get_work_order_cost_data, seven_days_range_tuple, prefix)
    }
  end

  def msl_breach_count_data(site_id, widget_config, prefix) do
    %{
      id: 22,
      key: "MSLBC",
      name: "MSL Breach Count",
      chart_data: get_breached_items(site_id, prefix),
      unit: "",
      size: widget_config.size,
      type: 1
    }
  end

  def ppm_plan_data(site_id, widget_config, prefix) do
    %{
      id: 23,
      key: "PPMPL",
      name: "Planner for PPM - Compliance",
      chart_data: get_ppm_plan(site_id, prefix),
      unit: "",
      size: widget_config.size,
      type: 1
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

    # energy_meters = Helpers.get_sub_meter_assets(config, "E", prefix)
    energy_meters = config["energy_non_main_meters"] |> convert_nil_to_list()

    asset_and_energy_list = Helpers.get_assets_and_energy_list(energy_meters, from_dt, to_dt, prefix)

    [Enum.at(asset_and_energy_list, 0), Enum.at(asset_and_energy_list, 1), Enum.at(asset_and_energy_list, 2)]
    |> Stream.filter(&(not is_nil(&1)))
    |> Enum.map(fn {asset, value} ->

        asset =
          if is_map(asset) do
            AssetConfig.get_equipment!(asset["id"], prefix)
          else
            AssetConfig.get_equipment!(asset, prefix)
          end

      %{name: asset.name, val: convert_to_ceil_float(value)}

    end)
  end

  def get_energy_of_sub_meters_for_24_hours(site_id, config, prefix) do
    to_dt = get_site_date_time_now(site_id, prefix)
    from_dt = NaiveDateTime.add(to_dt, -86400)

    # energy_meters = Helpers.get_sub_meter_assets(config, "E", prefix)
    energy_meters = config["energy_non_main_meters"] |> convert_nil_to_list()

    asset_and_energy_list = Helpers.get_assets_and_energy_list(energy_meters, from_dt, to_dt, prefix)

    asset_and_energy_list
    |> Stream.filter(&(not is_nil(&1)))
    |> Enum.map(fn {asset, value} ->

        asset =
          if is_map(asset) do
            AssetConfig.get_equipment!(asset["id"], prefix)
          else
            AssetConfig.get_equipment!(asset, prefix)
          end

      %{name: asset.name, val: convert_to_ceil_float(value)}

    end)
  end

  def get_segr_for_24_hours(site_id, config, prefix) do
    to_dt = get_site_date_time_now(site_id, prefix)
    from_dt = NaiveDateTime.add(to_dt, -86400)

    generators = config["generators"]

    energy_consumption = NumericalData.get_energy_consumption_for_assets(generators, from_dt, to_dt, prefix)
                        |> change_nil_to_zero()

    fuel_consumption = NumericalData.get_fuel_consumption_for_assets(generators, from_dt, to_dt, prefix)
                      |> change_nil_to_one()

    energy_consumption / fuel_consumption
  end

  def get_ppm_compliance(site_id, prefix) do
    {from_date, to_date} = get_month_date_till_now(site_id, prefix)

    workorders = NumericalData.get_workorder_for_chart(site_id, from_date, to_date, "PRV", prefix)

    scheduled_wo = workorders |> Enum.count() |> change_nil_to_one()
    completed_wo = workorders |> Enum.count(fn wo -> wo.status in @completed_workorders end)

    calculate_percentage(completed_wo, scheduled_wo)
  end

  def get_open_workorder_status(site_id, prefix) do
    {from_date, to_date} = get_month_date_till_now(site_id, prefix)

    workorders = NumericalData.get_workorder_for_chart(site_id, from_date, to_date, nil, prefix) |> Enum.filter(fn wo -> wo.status not in @completed_workorders end)

    open_wo = workorders |> Enum.count() |> change_nil_to_one()
    inprogress_wo = workorders |> Enum.count(fn wo -> wo.status not in @open_workorders end)

    calculate_percentage(inprogress_wo, open_wo)
  end

  def get_open_ticket_status(site_id, prefix) do
    {from_datetime, to_datetime} = get_month_date_time_till_now(site_id, prefix)
    NumericalData.get_work_requests(site_id, from_datetime, to_datetime, ["CL", "CP", "RJ", "CS"], "not", prefix)
    |> Enum.count()
    |> convert_to_ceil_float()
  end

  def get_ticket_workorder_status_chart(site_id, prefix) do
    {from_date, to_date} = get_month_date_till_now(site_id, prefix)

    total_wo = NumericalData.get_service_workorder_for_chart(site_id, from_date, to_date, prefix)
    total_count = total_wo |> length() |> change_nil_to_one()
    open_count = Enum.count(total_wo, fn wo -> wo.status in @open_workorders end)
    completed_count = Enum.count(total_wo, fn wo -> wo.status in @completed_workorders end)
    inprogress_count = Enum.count(total_wo, fn wo -> wo.status not in @open_workorders ++ @completed_workorders end)

    [
      %{
        label: "Open",
        value: calculate_percentage(open_count, total_count),
        color: "#ff0000"
      },
      %{
        label: "In Progress",
        value: calculate_percentage(inprogress_count, total_count),
        color: "#ffbf00"
      },
      %{
        label: "Closed",
        value: calculate_percentage(completed_count, total_count),
        color: "#00ff00"
      }
    ]
  end

  def get_breakdown_workorder_status_shcart(site_id, prefix) do
    {from_date, to_date} = get_month_date_till_now(site_id, prefix)
    NumericalData.get_breakdown_workorder_for_chart(site_id, from_date, to_date, prefix)
    |> length()
  end

  def get_equipment_under_maintenance(site_id, prefix) do
    NumericalData.get_equipment_with_status("OFF", %{"site_id" => site_id}, prefix)
    |> length()
  end

  def get_mtbf(site_id, prefix) do
    {from_dt, to_dt} = get_year_to_date_time(site_id, prefix)
    AssetConfig.list_equipments(site_id, prefix)
    |> Stream.map(&Task.async(fn -> NumericalData.get_mtbf_of_equipment(&1.id, from_dt, to_dt, prefix) end))
    |> Stream.map(&Task.await/1)
    |> Enum.sum()
    |> convert_to_hours_and_minutes()
  end

  def get_mttr(site_id, prefix) do
    {from_dt, to_dt} = get_year_to_date_time(site_id, prefix)
    AssetConfig.list_equipments(site_id, prefix)
    |> Stream.map(&Task.async(fn -> NumericalData.get_mttr_of_equipment(&1.id, from_dt, to_dt, prefix) end))
    |> Stream.map(&Task.await/1)
    |> Enum.sum()
    |> convert_to_hours_and_minutes()
  end

  def get_intime_reporting(site_id, prefix) do
    to_dt = get_site_date_time_now(site_id, prefix)
    from_dt = NaiveDateTime.add(to_dt, -86400)

    expected_rosters = NumericalData.get_expected_rosters(site_id, NaiveDateTime.to_date(from_dt), NaiveDateTime.to_date(to_dt), prefix) |> Enum.count() |> change_nil_to_one()
    actual_attendances =
      NumericalData.get_attendances(site_id, from_dt, to_dt, prefix)
      |> Stream.filter(fn att ->
          Time.compare(NaiveDateTime.to_time(att.in_time), att.shift_start) != :gt
        end)
      |> Enum.count()

    (actual_attendances / expected_rosters) *100
  end

  def get_shift_coverage(site_id, prefix) do
    to_dt = get_site_date_time_now(site_id, prefix)
    from_dt = NaiveDateTime.add(to_dt, -86400)

    expected_rosters = NumericalData.get_expected_rosters(site_id, NaiveDateTime.to_date(from_dt), NaiveDateTime.to_date(to_dt), prefix) |> Enum.count() |> change_nil_to_one()
    actual_attendances = NumericalData.get_attendances(site_id, from_dt, to_dt, prefix) |> Enum.count()

    (actual_attendances / expected_rosters) *100
  end

  def get_work_order_cost(site_id, prefix) do
    NumericalData.get_work_order_numerical_cost(site_id, prefix)
    |> Stream.map(fn wo -> wo.cost end)
    |> Stream.filter(fn cost -> not is_nil(cost) end)
    |> Enum.sum()
    |> convert_to_ceil_float()
  end

  def get_breached_items(site_id, prefix) do
    NumericalData.breached_items_count_for_site(site_id, prefix)
  end

  def get_ppm_plan(site_id, prefix) do
    date = get_site_date_now(site_id, prefix)
    NumericalData.get_schedules_for_today(site_id, date, prefix)
    |> Inconn2Service.Report.get_calculated_dates_for_schedules(date, date, [], prefix)
    |> Enum.map(fn {_k, v} -> length(v) end)
    |> List.first()
    |> change_nil_to_zero()
    |> convert_to_ceil_float()
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
      %{widget_code: "MTTRA", position: 18 },
      %{widget_code: "INTRE", position: 19 },
      %{widget_code: "SHFCV", position: 20 },
      %{widget_code: "COSMN", position: 21 },
      %{widget_code: "MSLBC", position: 22 },
      %{widget_code: "PPMPL", position: 23 }
      ]
  end

  def get_chart_data_energy(_site_id, 1, numerical_func, _indivdual_chart_func, _config, _seven_days_range_tuple, _prefix) do
    numerical_func.()
  end

  def get_chart_data_energy(site_id, 2, _numerical_func, indivdual_chart_func, config, {seven_days_start, seven_days_end}, prefix) do
    params = %{
      "site_id" => site_id,
      "from_date" => seven_days_start |> Date.to_iso8601(),
      "to_date" => seven_days_end |> Date.to_iso8601(),
      "asset_ids" => config["energy_main_meters"]
    }
    apply(DashboardCharts, indivdual_chart_func, [params, prefix])
  end

  def get_chart_data_water(_site_id, 1, numerical_func, _indivdual_chart_func, _config, _seven_days_range_tuple, _prefix) do
    numerical_func.()
  end

  def get_chart_data_water(site_id, 2, _numerical_func, indivdual_chart_func, config, {seven_days_start, seven_days_end}, prefix) do
    params = %{
      "site_id" => site_id,
      "from_date" => seven_days_start |> Date.to_iso8601(),
      "to_date" => seven_days_end |> Date.to_iso8601(),
      "asset_ids" => config["water_main_meters"]
    }
    apply(DashboardCharts, indivdual_chart_func, [params, prefix])
  end

  def get_chart_data_fuel(_site_id, 1, numerical_func, _indivdual_chart_func, _config, _seven_days_range_tuple, _prefix) do
    numerical_func.()
  end

  def get_chart_data_fuel(site_id, 2, _numerical_func, indivdual_chart_func, config, {seven_days_start, seven_days_end}, prefix) do
    params = %{
      "site_id" => site_id,
      "from_date" => seven_days_start |> Date.to_iso8601(),
      "to_date" => seven_days_end |> Date.to_iso8601(),
      "asset_ids" => config["fuel_main_meters"]
    }
    apply(DashboardCharts, indivdual_chart_func, [params, prefix])
  end

  def get_chart_data_work_order_and_ticket(_site_id, 1, numerical_func, _indivdual_chart_func, _seven_days_range_tuple, _prefix) do
    numerical_func.()
  end

  def get_chart_data_work_order_and_ticket(site_id, 2, _numerical_func, indivdual_chart_func, {seven_days_start, seven_days_end}, prefix) do
    params = %{
      "site_id" => site_id,
      "from_date" => seven_days_start |> Date.to_iso8601(),
      "to_date" => seven_days_end |> Date.to_iso8601()
    }
    apply(DashboardCharts, indivdual_chart_func, [params, prefix])
  end

  def get_chart_data_intime_and_shift(_site_id, 1, numerical_func, _indivdual_chart_func, _seven_days_range_tuple, _user, _prefix) do
    numerical_func.()
  end

  def get_chart_data_intime_and_shift(site_id, 2, _numerical_func, indivdual_chart_func, {seven_days_start, seven_days_end}, user, prefix) do
    params = %{
      "site_id" => site_id,
      "from_date" => seven_days_start |> Date.to_iso8601(),
      "to_date" => seven_days_end |> Date.to_iso8601(),
      "shift_ids" => Settings.list_shift_ids(site_id, prefix),
      "org_unit_ids" => Staff.list_org_unit_ids_for_user(user, prefix)
    }
    apply(DashboardCharts, indivdual_chart_func, [params, prefix])
  end

  def get_chart_data_workorder_cost(_site_id, 1, numerical_func, _indivdual_chart_func, _seven_days_range_tuple, _prefix) do
    numerical_func.()
  end

  def get_chart_data_workorder_cost(site_id, 2, _numerical_func, indivdual_chart_func, {seven_days_start, seven_days_end}, prefix) do
    params = %{
      "site_id" => site_id,
      "from_date" => seven_days_start |> Date.to_iso8601(),
      "to_date" => seven_days_end |> Date.to_iso8601()
    }
    apply(DashboardCharts, indivdual_chart_func, [params, prefix])
  end

  # Chart types:
  # 1 => Number
  # 2 => Table
  # 3 => Pie Chart
  # 4 => Trend Line
  # 5 => Bar Chart

  def get_chart_type("ENCON", 2), do: 4
  def get_chart_type("ENCOS", 2), do: 4
  def get_chart_type("ENPEI", 2), do: 5
  def get_chart_type("WACON", 2), do: 4
  def get_chart_type("WACOS", 2), do: 4
  def get_chart_type("FUCON", 2), do: 5
  def get_chart_type("FUCOS", 2), do: 4
  def get_chart_type("PPMCW", 2), do: 5
  def get_chart_type("OPWOR", 2), do: 5
  def get_chart_type("OPTIC", 2), do: 5
  def get_chart_type("SEWOR", 1), do: 3
  def get_chart_type("SEWOR", 2), do: 5
  def get_chart_type("INTRE", 2), do: 5
  def get_chart_type("SHFCV", 2), do: 4
  def get_chart_type("COSMN", 2), do: 4
  def get_chart_type(_, _), do: 1

end
