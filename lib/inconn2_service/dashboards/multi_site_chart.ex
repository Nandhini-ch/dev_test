# defmodule Inconn2Service.Dashboards.MultiSiteChart do

#   import Inconn2Service.Util.HelpersFunctions
#   alias Inconn2Service.Settings
#   alias Inconn2Service.Staff
#   alias Inconn2Service.Dashboards.{NumericalData, Helpers}
#   alias Inconn2Service.DashboardConfiguration
#   alias Inconn2Service.Dashboards.NumericalData
#   alias Inconn2Service.Dashboards.DashboardCharts
#   alias Inconn2Service.DashboardConfiguration.UserWidgetConfig

#   # def get_multi_site_dashboard_chart(site_ids, device, user, widget_code, prefix) do
#   #   Enum.map(fn x -> get_multi_site_chart(x, site_id, "Web", user_id, prefix) end)
#   # end

#   def get_multi_site_chart(site_id, device, user_id, prefix) do
#     config = get_site_config_for_dashboards(site_id, prefix)

#     seven_day_end = get_site_date_now(site_id, prefix)
#     seven_day_start = Date.add(seven_day_end, -7)

#     energy_consumption =
#       NumericalChart.get_energy_consumption_for_24_hours(site_id, config, prefix)
#       |> change_nil_to_zero()

#     water_consumption =
#       NumericalChart.get_water_consumption_for_24_hours(site_id, config, prefix)
#       |> change_nil_to_zero()

#     fuel_consumption =
#       NumericalChart.get_fuel_consumption_for_24_hours(site_id, config, prefix)
#       |> change_nil_to_zero()

#     user_widget_config =
#       DashboardConfiguration.list_user_widget_configs_for_user(user_id, device, prefix)

#     # NumericalChart.get_individual_data(user_widget_config, energy_consumption, water_consumption, fuel_consumption, config, site_id, {seven_day_start, seven_day_end}, user, prefix)
#   end
# end
