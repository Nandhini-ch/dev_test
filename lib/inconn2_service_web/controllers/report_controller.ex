defmodule Inconn2ServiceWeb.ReportController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Report

  action_fallback Inconn2ServiceWeb.FallbackController


  def get_work_order_report(conn, _params) do
    work_order_report_data = Report.get_work_order_report(conn.assigns.sub_domain_prefix)
    render(conn, "work_order_report.json", work_order_info: work_order_report_data)
  end
end
