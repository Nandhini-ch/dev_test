defmodule Inconn2Service.Dashboards.NumericalChart do

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Dashboards.{NumericalData, Helpers}
  alias Inconn2Service.AssetConfig

  def get_numerical_charts_for_24_hours(site_id, prefix) do

    config = get_site_config_for_dashboards(site_id, prefix)

    energy_consumption =
      get_energy_consumption_for_24_hours(site_id, config, prefix)
      |> change_nil_to_zero()

    energy_cost_per_unit = change_nil_to_zero(config["energy_cost_per_unit"])
    energy_cost = energy_consumption * energy_cost_per_unit

    area_in_sqft = change_nil_to_one(config["area"])
    epi = energy_consumption / area_in_sqft

    top_3_data_list = get_top_three_consumers_for_24_hours(site_id, config, prefix)

    water_consumption =
      get_water_consumption_for_24_hours(site_id, config, prefix)
      |> change_nil_to_zero()

    water_cost_per_unit = change_nil_to_zero(config["water_cost_per_unit"])
    water_cost = water_consumption * water_cost_per_unit

    fuel_consumption =
      get_fuel_consumption_for_24_hours(site_id, config, prefix)
      |> change_nil_to_zero()

    fuel_cost_per_unit = change_nil_to_zero(config["fuel_cost_per_unit"])
    fuel_cost = fuel_consumption * fuel_cost_per_unit

    sub_meters_energy_data_list = get_energy_of_sub_meters_for_24_hours(site_id, config, prefix)

    segr = get_segr_for_24_hours(site_id, config, prefix)

    ppm_compliance = get_ppm_compliance(site_id, prefix)

    open_work_order_status = get_open_workorder_status(site_id, prefix)

    open_ticket_status = get_open_ticket_status(site_id, prefix)

    ticket_work_order_status = get_ticket_workorder_status_chart(site_id, prefix)

    breakdown_work_order_status = get_breakdown_workorder_status_shcart(site_id, prefix)

    equipments_under_maintenance = get_equipment_under_maintenance(site_id, prefix)

    mtbf = get_mtbf(site_id, prefix)

    mttr = get_mttr(site_id, prefix)

    [
      %{
        id: 1,
        key: "ENCON",
        name: "Energy Consumption",
        displayTxt: energy_consumption,
        unit: "kWh",
        type: 1
      },
      %{
        id: 2,
        key: "ENCOS",
        name: "Energy Cost",
        displayTxt: energy_cost,
        unit: "INR",
        type: 1
      },
      %{
        id: 3,
        key: "ENPEI",
        name: "Energy performance Indicator (EPI)",
        displayTxt: epi,
        unit: "kWh/sqft",
        type: 1
      },
      %{
        id: 4,
        key: "ENTOP",
        name: "Top 3 non main meter consumption",
        unit: "kWh",
        type: 2,
        tableInfo: %{
            headers: ["Name", "Consumption ( kWh )"],
            list: top_3_data_list
        }
      },
      %{
        id: 5,
        key: "WACON",
        name: "Water Consumption",
        displayTxt: water_consumption,
        unit: "kilo ltrs",
        type: 1
      },
      %{
        id: 6,
        key: "WACOS",
        name: "Water Cost",
        displayTxt: water_cost,
        unit: "INR",
        type: 1
      },
      %{
        id: 7,
        key: "FUCON",
        name: "Fuel Consumption",
        displayTxt: fuel_consumption,
        unit: "ltrs",
        type: 1
      },
      %{
        id: 8,
        key: "FUCOS",
        name: "Fuel Cost",
        displayTxt: fuel_cost,
        unit: "INR",
        type: 1
      },
      %{
        id: 9,
        key: "ENSUB",
        name: "Sub meters - Consumption",
        unit: "kWh",
        type: 2,
        tableInfo: %{
            headers: ["Name", "Consumption ( kWh )"],
            list: sub_meters_energy_data_list
        }
      },
      %{
        id: 10,
        key: "SEGRE",
        name: "SEGR",
        unit: "kwhr/litr",
        type: 1,
        displayTxt: segr
      },
      %{
        id: 11,
        key: "PPMCW",
        name: "PPM Compliance",
        unit: "%",
        type: 1,
        displayTxt: ppm_compliance
      },
      %{
        id: 12,
        key: "OPWOR",
        name: "Open/in-progress Workorder status",
        unit: "%",
        type: 1,
        displayTxt: open_work_order_status,
      },
      %{
        id: 13,
        key: "OPTIC",
        name: "Open/in-progress Ticket status",
        unit: "Tickets",
        type: 1,
        displayTxt: open_ticket_status,
      },
      %{
        id: 14,
        key: "SEWOR",
        name: "Service Workorder Status",
        unit: "%",
        type: 3,
        chartResp: ticket_work_order_status,
      },
      %{
        id: 15,
        key: "BRWOR",
        name: "Breakdown work Status – YTD",
        unit: "WorkOrders",
        type: 1,
        displayTxt: breakdown_work_order_status
      },
      %{
        id: 16,
        key: "EQUMN",
        name: "Equipment under maintenance at present",
        unit: "assets",
        type: 1,
        displayTxt: equipments_under_maintenance
     },
     %{
        id: 17,
        key: "MTBF",
        name: "Mean time between failures",
        unit: "YTD",
        type: 1,
        displayTxt: mtbf
      },
      %{
        id: 18,
        key: "MTTR",
        name: "Mean time between failures",
        unit: "YTD",
        type: 1,
        displayTxt: mttr
      }
    ]
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

end
