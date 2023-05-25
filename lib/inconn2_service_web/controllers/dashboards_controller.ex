defmodule Inconn2ServiceWeb.DashboardsController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Util.HierarchyManager
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Dashboards.{NumericalChart, DashboardCharts, Helpers, MultiSiteChart}
  alias Inconn2ServiceWeb.AssetCategoryView
  action_fallback Inconn2ServiceWeb.FallbackController

  def get_assets_for_dashboards(conn, %{"site_id" => site_id, "type" => type}) do
    assets = Helpers.get_assets_for_dashboards(site_id, type, conn.assigns.sub_domain_prefix)
    conn
    |> put_view(AssetCategoryView)
    |> render("assets.json", assets: assets)
  end

  def get_asset_categories_and_assets(conn, %{"location_id" => location_id}) do
    asset_categories = AssetConfig.list_asset_categories_for_location(location_id, conn.assigns.sub_domain_prefix)
    asset_categories_tree = asset_categories |> HierarchyManager.build_tree()
    {locations, equipments} = AssetConfig.get_assets_for_location(location_id, conn.assigns.sub_domain_prefix)
    render(conn, "assets_asset_categories.json", asset_categories: asset_categories, asset_categories_tree: asset_categories_tree, locations: locations, equipments: equipments)
  end

  def get_high_level_data_web(conn, %{"site_id" => site_id}) do
    data = NumericalChart.get_numerical_charts_for_24_hours(site_id, "web", conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "high_level.json", data: data)
  end

  def get_high_level_data_mobile(conn, %{"site_id" => site_id}) do
    data = NumericalChart.get_numerical_charts_for_24_hours(site_id, "mob", conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "high_level.json", data: data)
  end

  def get_multi_sites_dashboard_chart(conn, %{"site_ids" => site_ids, "device" => device, "widget_code" => widget_code}) do
    data = MultiSiteChart.get_multi_site_dashboard_chart(site_ids, device, widget_code, conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "high_level.json", data: data)
  end

  def get_energy_consumption(conn, params) do
    data = DashboardCharts.get_energy_consumption(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_energy_cost(conn, params) do
    data = DashboardCharts.get_energy_cost(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_energy_performance_indicator(conn, params) do
    data = DashboardCharts.get_energy_performance_indicator(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_top_three_consumers(conn, params) do
    data = DashboardCharts.get_top_three_consumers(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_water_consumption(conn, params) do
    data = DashboardCharts.get_water_consumption(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_water_cost(conn, params) do
    data = DashboardCharts.get_water_cost(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_fuel_consumption(conn, params) do
    data = DashboardCharts.get_fuel_consumption(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_fuel_cost(conn, params) do
    data = DashboardCharts.get_fuel_cost(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_submeters_consumption(conn, params) do
    data = DashboardCharts.get_consumption_for_submeters(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_segr(conn, params) do
    data = DashboardCharts.get_segr_for_generators(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_ppm_compliance_chart(conn, params) do
    data = DashboardCharts.get_ppm_chart(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_open_inprogress_wo_chart(conn, params) do
    data = DashboardCharts.get_open_workorder_chart(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_open_ticket_status_chart(conn, params) do
    data = DashboardCharts.get_ticket_open_status_chart(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_ticket_workorder_status_chart(conn, params) do
    data = DashboardCharts.get_ticket_workorder_status_chart(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_breakdown_workorder_status_chart(conn, params) do
    data = DashboardCharts.get_breakdown_workorder_status_chart(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_equipment_under_maintenance_chart(conn, params) do
    data = DashboardCharts.get_equipment_under_maintenance_chart(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_equipment_mtbf(conn, params) do
    data = DashboardCharts.get_mtbf_chart(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_equipment_mttr(conn, params) do
    data = DashboardCharts.get_mttr_chart(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_intime_reporting_chart(conn, params) do
    data = DashboardCharts.get_intime_reporting_chart(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_shift_coverage_chart(conn, params) do
    data = DashboardCharts.get_shift_coverage_chart(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_inventory_breach_chart(conn, params) do
    data = DashboardCharts. get_inventory_breach_data(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end

  def get_work_order_cost(conn, params) do
    data = DashboardCharts.get_work_order_cost_data(params, conn.assigns.sub_domain_prefix)
    render(conn, "detailed_charts.json", data: data)
  end
end
