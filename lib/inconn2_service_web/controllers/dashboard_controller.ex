defmodule Inconn2ServiceWeb.DashboardController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Dashboard

  def get_work_order_pie_chart(conn, _) do
    work_order_counts = Dashboard.work_order_pie_chart(conn.assigns.sub_domain_prefix, conn.query_params)
    render(conn, "work_order_pie.json", work_order_counts: work_order_counts)
  end

  def get_workflow_pie_chart(conn, _) do
    workflow_data = Dashboard.work_flow_pie_chart(conn.assigns.sub_domain_prefix, conn.query_params)
    render(conn, "workflow_pie_chart.json", workflow_data: workflow_data)
  end

  def get_metering_linear_chart(conn, _) do
    metering_data = Dashboard.get_trendline_for_metering(conn.assigns.sub_domain_prefix, conn.query_params)
    render(conn, "workflow_pie_chart.json", workflow_data: metering_data)
  end

  def get_work_order_bar_chart(conn, _) do
    work_order_counts = Dashboard.work_order_bar_chart(conn.assigns.sub_domain_prefix, conn.query_params)
    render(conn, "work_order_bar.json", work_order_counts: work_order_counts)
  end
end
