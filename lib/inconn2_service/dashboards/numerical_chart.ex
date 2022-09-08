defmodule Inconn2Service.Dashboards.NumericalChart do

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Dashboards.NumericalData

  def get_numerical_charts_for_24_hours(site_id, prefix) do

    config = get_site_config_for_dashboards(site_id, prefix)

    energy_consumption =
      get_energy_consumption_for_24_hours(site_id, config, prefix)
      |> change_nil_to_zero()

    energy_cost_per_unit = change_nil_to_zero(config["energy_cost_per_unit"])
    energy_cost = energy_consumption * energy_cost_per_unit

    area_in_sqft = change_nil_to_one(config["area"])
    epi = energy_consumption / area_in_sqft

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

  def get_work_order_scheduled_chart(site_id, prefix) do
    {from_date, to_date} = get_month_date_till_now(site_id, prefix)
    NumericalData.progressing_workorders(site_id, from_date, to_date, prefix) |> Enum.count()
    NumericalData.completed_workorders(site_id, from_date, to_date, prefix) |> Enum.count()
  end

end
