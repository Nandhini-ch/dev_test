defmodule Inconn2Service.Dashboards.NumericalChart do

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Dashboards.NumericalData

  def get_numerical_charts_for_24_hours(site_id, prefix) do

    energy_consumption =
      get_energy_meter_for_24_hours(site_id, prefix)
      |> change_nil_to_zero()

    [
      %{
        id: 1,
        key: "ENCON",
        name: "Energy Consumption",
        displayTxt: energy_consumption,
        unit: "kWh",
        type: 1
      }
    ]

  end

  def get_energy_meter_for_24_hours(site_id, prefix) do
    config = get_site_config_for_dashboards(site_id, prefix)
    to_dt = get_site_date_time_now(site_id, prefix)
    from_dt = NaiveDateTime.add(to_dt, -86400)
    NumericalData.get_energy_consumption_for_assets(config["energy_main_meters"], from_dt, to_dt, prefix)
  end

end
