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

    ppm_compliance = get_work_order_scheduled_chart(site_id, prefix)

    open_work_orders = get_workorder_inprogress_number(site_id, prefix)

    open_ticket_status = get_open_ticket_status(site_id, prefix)

    work_order_statuses = get_workorder_status_chart(site_id, prefix)

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
        displaytTxt: ppm_compliance
      },
      %{
        id: 12,
        key: "OPWOR",
        name: "Open/in-progress Workorder status",
        unit: "%",
        type: 1,
        displayTxt: open_work_orders,
      },
      %{
        id: 13,
        key: "OPTIC",
        name: "Open/in-progress Ticket status",
        unit: "%",
        type: 1,
        displayTxt: open_ticket_status,
      },
      %{
        id: 14,
        key: "SEWOR",
        name: "Service Workorder Status",
        unit: "%",
        type: 3,
        chartResp: work_order_statuses,
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

    energy_consumption / fuel_consumption
  end

  def get_work_order_scheduled_chart(site_id, prefix) do
    {from_date, to_date} = get_month_date_till_now(site_id, prefix)
    div(
      NumericalData.progressing_workorders(site_id, from_date, to_date, prefix) |> Enum.count(),
      NumericalData.completed_workorders(site_id, from_date, to_date, prefix) |> Enum.count() |> change_nil_to_one()
    ) * 100
  end

  def get_workorder_inprogress_number(site_id, prefix) do
    {from_date, to_date} = get_month_date_till_now(site_id, prefix)
    NumericalData.in_progress_workorders(site_id, from_date, to_date, prefix) |> Enum.count()
  end

  def get_open_ticket_status(site_id, prefix) do
    {from_datetime, to_datetime} = get_month_date_time_till_now(site_id, prefix)
    div(
      NumericalData.inprogress_tickets(site_id, from_datetime, to_datetime, prefix) |> Enum.count(),
      NumericalData.get_open_tickets(site_id, from_datetime, to_datetime, prefix) |> Enum.count() |> change_nil_to_one()
    ) * 100
  end

  def get_workorder_status_chart(site_id, prefix) do
    {from_date, to_date} = get_month_date_till_now(site_id, prefix)
    [
      %{
        label: "Open",
        value: div(
                   NumericalData.open_workorders(site_id, from_date, to_date, prefix) |> length(),
                   NumericalData.get_for_workorder_count(site_id, from_date, to_date, prefix) |> length() |> change_nil_to_one()
                   ) * 100,
        color: "#ff0000"
      },
      %{
        label: "In Progress",
        value: div(
                    NumericalData.in_progress_workorders(site_id, from_date, to_date, prefix) |> length(),
                    NumericalData.get_for_workorder_count(site_id, from_date, to_date, prefix) |> length() |> change_nil_to_one()
                    ) * 100,
        color: "#00ff00"
      },
      %{
        label: "Closed",
        value: div(
                    NumericalData.completed_workorders(site_id, from_date, to_date, prefix) |> length(),
                    NumericalData.get_for_workorder_count(site_id, from_date, to_date, prefix) |> length() |> change_nil_to_one()
                    ) * 100,
        color: "#ffbf00"
      }
    ]
  end
end
