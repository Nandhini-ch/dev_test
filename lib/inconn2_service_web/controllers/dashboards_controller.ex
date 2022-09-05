defmodule Inconn2ServiceWeb.DashboardsController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Dashboards.{NumericalChart, DashboardCharts}

  action_fallback Inconn2ServiceWeb.FallbackController

  def get_high_level_data(conn, %{"site_id" => site_id}) do
    data = NumericalChart.get_numerical_charts_for_24_hours(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "high_level.json", data: data)
  end

  def get_energy_consumption(conn, params) do
    data = DashboardCharts.get_energy_consumption(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_energy_performance_indicator(conn, params) do
    data = DashboardCharts.get_energy_performance_indicator(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

end
