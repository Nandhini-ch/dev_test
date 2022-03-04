defmodule Inconn2ServiceWeb.DashboardController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Dashboards

  def get_energy_meter_linear_chart(conn, _) do
    energy_meter_data = Dashboards.get_energy_meter_linear_chart_random(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "energy_meter.json", energy_meter_data: energy_meter_data)
  end

  def get_workflow_ticket_pie_chart(conn, _) do
    workflow_data = Dashboards.ticket_linear_chart(conn.assigns.sub_domain_prefix, conn.query_params)
    render(conn, "workflow_linear_data.json", workflow_data: workflow_data)
  end

  def get_workflow_workorder_pie_chart(conn, _) do
    workflow_data = Dashboards.work_order_linear_chart(conn.assigns.sub_domain_prefix, conn.query_params)
    render(conn, "workflow_linear_data.json", workflow_data: workflow_data)
  end

  def get_energy_meter_speedometer(conn, _) do
    energy_meter_data = Dashboards.get_energy_meter_speedometer_random(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "energy_meter.json", energy_meter_data: energy_meter_data)
  end
  # def get_work_order_pie_chart(conn, _) do
  #   work_order_counts = Dashboard.work_order_pie_chart(conn.assigns.sub_domain_prefix, conn.query_params)
  #   render(conn, "work_order_pie.json", work_order_counts: work_order_counts)
  # end

  # def get_workflow_pie_chart(conn, _) do
  #   workflow_data = Dashboard.work_flow_pie_chart(conn.assigns.sub_domain_prefix, conn.query_params)
  #   render(conn, "workflow_pie_chart.json", workflow_data: workflow_data)
  # end

  # def get_metering_linear_chart(conn, _) do
  #   metering_linear_data = Dashboard.get_metering_linear_chart(conn.assigns.sub_domain_prefix, conn.query_params)
  #   render(conn, "metering_linear_chart.json", metering_linear_data: metering_linear_data)
  # end

  # def get_work_order_bar_chart(conn, _) do
  #   work_order_counts = Dashboard.work_order_bar_chart(conn.assigns.sub_domain_prefix, conn.query_params)
  #   render(conn, "work_order_bar.json", work_order_counts: work_order_counts)
  # end

  # def get_asset_status_pie_chart(conn, _params) do
  #   asset_status_data = Dashboard.asset_status_pie_chart(conn.assigns.sub_domain_prefix, conn.query_params)
  #   render(conn, "asset_staus_pie.json", asset_status_data: asset_status_data)
  # end
end
