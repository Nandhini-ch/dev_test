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

  def get_workflow_report(conn, _params) do
    {result, summary} = Report.work_status_report(conn.assigns.sub_domain_prefix, conn.query_params)
    case conn.query_params["type"] do
      "pdf" ->
        conn
        |> put_resp_content_type("application/pdf")
        |> put_resp_header("content-disposition", "attachment; filename=\"work_order_report.pdf\"")
        |> send_resp(200, result)

      "csv" ->
        csv = result |> CSV.encode() |> Enum.to_list() |> to_string
        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("content-disposition", "attachment; filename=\"work_order_report.csv\"")
        |> send_resp(200, csv)

      _ ->
        render(conn, "work_order_report.json", work_order_info: result, summary: summary)
    end
  end

  def get_workflow_execution_report(conn, _params) do
    result = Report.execution_data(conn.assigns.sub_domain_prefix, conn.query_params)
    case conn.query_params["type"] do
      "pdf" ->
        conn
        |> put_resp_content_type("application/pdf")
        |> put_resp_header("content-disposition", "attachment; filename=\"work_order_report.pdf\"")
        |> send_resp(200, result)

      "csv" ->
        csv = result |> CSV.encode() |> Enum.to_list() |> to_string
        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("content-disposition", "attachment; filename=\"work_order_report.csv\"")
        |> send_resp(200, csv)

       _ ->
        case conn.query_params["task_type"] do
          "mt" ->
            render(conn, "work_order_exec_meter.json", work_order_exec_info: result)
          _ ->
            render(conn, "work_order_exec.json", work_order_exec_info: result)
        end
    end
  end

  def get_calendar(conn, _params) do
    calendar = Report.calendar(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "calendar.json", calendar: calendar)
  end

  def get_work_request_report(conn, _params) do
    {result, summary} = Report.work_request_report(conn.assigns.sub_domain_prefix, conn.query_params)
    case conn.query_params["type"] do
      "pdf" ->
        conn
        |> put_resp_content_type("application/pdf")
        |> put_resp_header("content-disposition", "attachment; filename=\"work_request_report.pdf\"")
        |> send_resp(200, result)

      "csv" ->
        csv = result |> CSV.encode() |> Enum.to_list() |> to_string
        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("content-disposition", "attachment; filename=\"work_request_report.csv\"")
        |> send_resp(200, csv)

      _ ->
        render(conn, "work_order_report.json", work_order_info: result, summary: summary)
    end
  end

  def get_asset_status_report(conn, _params) do
    {result, summary} = Report.asset_status_report(conn.assigns.sub_domain_prefix, conn.query_params)
    case conn.query_params["type"] do
      "pdf" ->
        conn
        |> put_resp_content_type("application/pdf")
        |> put_resp_header("content-disposition", "attachment; filename=\"asset_status_report.pdf\"")
        |> send_resp(200, result)

      "csv" ->
        csv = result |> CSV.encode() |> Enum.to_list() |> to_string
        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("content-disposition", "attachment; filename=\"asset_status_report.csv\"")
        |> send_resp(200, csv)

      _ ->
        render(conn, "work_order_report.json", work_order_info: result, summary: summary)
    end
  end

  def get_people_report(conn, _params) do
    result = Report.people_report(conn.assigns.sub_domain_prefix, conn.query_params)
    case conn.query_params["type"] do
      "pdf" ->
        conn
        |> put_resp_content_type("application/pdf")
        |> put_resp_header("content-disposition", "attachment; filename=\"asset_status_report.pdf\"")
        |> send_resp(200, result)

      "csv" ->
        csv = result |> CSV.encode() |> Enum.to_list() |> to_string
        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("content-disposition", "attachment; filename=\"asset_status_report.csv\"")
        |> send_resp(200, csv)

      _ ->
        render(conn, "people_report.json", people_info: result)
    end
  end

  def get_workorder_status_report(conn, _) do
    workorder_status_report_data = Report.csg_workorder_report(conn.assigns.sub_domain_prefix, conn.query_params)
    conn
    |> put_resp_content_type("application/pdf")
    |> send_resp(:ok, workorder_status_report_data)
  end

  def get_locations_qr(conn, %{"site_id" => site_id}) do
    qrs = Report.generate_qr_code_for_locations(site_id, conn.assigns.sub_domain_prefix)
    conn
    |> put_resp_content_type("application/pdf")
    |> put_resp_header("content-disposition", "attachment; filename=\"location_qrs.pdf\"")
    |> send_resp(:ok, qrs)
  end

  def get_locations_ticket_qr(conn, %{"site_id" => site_id}) do
    qrs = Report.generate_ticket_qr_code_for_locations(site_id, conn.assigns.sub_domain_prefix)
    conn
    |> put_resp_content_type("application/pdf")
    |> put_resp_header("content-disposition", "attachment; filename=\"location_qrs.pdf\"")
    |> send_resp(:ok, qrs)
  end

  def get_equipments_qr(conn, %{"site_id" => site_id}) do
    qrs = Report.generate_qr_code_for_equipments(site_id, conn.assigns.sub_domain_prefix)
    conn
    |> put_resp_content_type("application/pdf")
    |> put_resp_header("content-disposition", "attachment; filename=\"equipment_qrs.pdf\"")
    |> send_resp(:ok, qrs)
  end

  def get_equipments_ticket_qr(conn, %{"site_id" => site_id}) do
    qrs = Report.generate_ticket_qr_code_for_equipments(site_id, conn.assigns.sub_domain_prefix)
    conn
    |> put_resp_content_type("application/pdf")
    |> put_resp_header("content-disposition", "attachment; filename=\"equipment_qrs.pdf\"")
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
    {inventory_report_data, summary} = Report.inventory_report(conn.assigns.sub_domain_prefix, conn.query_params)
    case conn.query_params["type"] do
      "pdf" ->
        conn
        |> put_resp_content_type("application/pdf")
        |> put_resp_header("content-disposition", "attachment; filename=\"asset_status_report.pdf\"")
        |> send_resp(200, inventory_report_data)

      "csv" ->
        csv = inventory_report_data |> CSV.encode() |> Enum.to_list() |> to_string
        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("content-disposition", "attachment; filename=\"asset_status_report.csv\"")
        |> send_resp(200, csv)

      _ ->
        render(conn, "inventory_report.json", inventory_info: inventory_report_data, summary: summary)
    end
  end
end
