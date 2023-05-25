defmodule Inconn2Service.Dashboards.MultiSiteChart do

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Dashboards.NumericalChart

  def get_multi_site_dashboard_chart(site_ids, device, widget_code, user, prefix) do
    site_ids
    |> convert_string_ids_to_list_of_ids()
    |> Enum.map(fn site_id -> get_multi_site_chart(site_id, widget_code, device, user, prefix) end)
    |> add_and_form_multi_site_widget(widget_code)
  end

  def get_multi_site_chart(site_id, widget_code, _device, user, prefix) do
    config = get_site_config_for_dashboards(site_id, prefix)

    seven_day_end = get_site_date_now(site_id, prefix)
    seven_day_start = Date.add(seven_day_end, -7)

    energy_consumption =
      NumericalChart.get_energy_consumption_for_24_hours(site_id, config, prefix)
      |> change_nil_to_zero()

    water_consumption =
      NumericalChart.get_water_consumption_for_24_hours(site_id, config, prefix)
      |> change_nil_to_zero()

    fuel_consumption =
      NumericalChart.get_fuel_consumption_for_24_hours(site_id, config, prefix)
      |> change_nil_to_zero()

    user_widget_config =
      %{
        widget_code: widget_code,
        position: 1,
        size: 1
      }

    site = AssetConfig.get_site!(site_id, prefix)

    NumericalChart.get_individual_data(user_widget_config, energy_consumption, water_consumption, fuel_consumption, config, site_id, {seven_day_start, seven_day_end}, user, prefix)
    |> Map.put(:name, site.name)
  end

  defp add_and_form_multi_site_widget(individual_widgets, widget_code) do
    [one_widget | _] = individual_widgets
    data =
      individual_widgets
      |> Enum.map(fn widget -> widget.chart_data end)
      |> Enum.sum()

    multi_site_widget =
      %{
        id: 0,
        key: widget_code,
        name: "All sites",
        chart_data: convert_to_ceil_float(data),
        unit: one_widget.unit,
        size: 1,
        type: 1
      }

    [multi_site_widget | individual_widgets]
  end

end
