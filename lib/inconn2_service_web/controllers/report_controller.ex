defmodule Inconn2ServiceWeb.ReportController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Report

  action_fallback Inconn2ServiceWeb.FallbackController


  def get_work_order_report(conn, _params) do
    work_order_report_data = Report.ppm_report_query(conn.query_params, conn.assigns.sub_domain_prefix)
    # render(conn, "work_order_report.json", work_order_info: work_order_report_data)
    conn
    |> put_resp_content_type("application/pdf")
    # |> put_resp_header("content-disposition", "attachment; filename=\"workorder_pdf.pdf\"")
    |> send_resp(:ok, work_order_report_data)
  end

  def get_workorder_status_report(conn, _) do
    workorder_status_report_data = Report.csg_workorder_report(conn.assigns.sub_domain_prefix)
    conn
    |> put_resp_content_type("application/pdf")
    |> send_resp(:ok, workorder_status_report_data)
  end

  def get_locations_qr(conn, %{"site_id" => site_id}) do
    qrs = Report.generate_qr_code_for_assets(site_id, conn.assigns.sub_domain_prefix)
    conn
    |> put_resp_content_type("application/pdf")
    |> send_resp(:ok, qrs)
  end

  def get_complaint_report(conn, _params) do
    complaint_report_data = Report.complaints_report(conn.assigns.sub_domain_prefix)
    # render(conn, "work_order_report.json", work_order_info: work_order_report_data)
    conn
    |> put_resp_content_type("application/pdf")
    # |> put_resp_header("content-disposition", "attachment; filename=\"workorder_pdf.pdf\"")
    |> send_resp(:ok, complaint_report_data)
  end

  def get_inventory_report(conn, _params) do
    inventory_report_data = Report.inventory_report(conn.assigns.sub_domain_prefix)
    render(conn, "inventory_report.json", inventory_info: inventory_report_data)
  end
end
