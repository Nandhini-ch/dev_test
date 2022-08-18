defmodule Inconn2ServiceWeb.MyReportController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Reports
  alias Inconn2Service.Reports.MyReport

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    my_reports = Reports.list_my_reports(conn.assigns.sub_domain_prefix, conn.assigns.current_user)
    render(conn, "index.json", my_reports: my_reports)
  end

  def create(conn, %{"my_report" => my_report_params}) do
    with {:ok, %MyReport{} = my_report} <- Reports.create_my_report(my_report_params, conn.assigns.current_user, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.my_report_path(conn, :show, my_report))
      |> render("show.json", my_report: my_report)
    end
  end

  def show(conn, %{"id" => id}) do
    my_report = Reports.get_my_report!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", my_report: my_report)
  end

  def update(conn, %{"id" => id, "my_report" => my_report_params}) do
    my_report = Reports.get_my_report!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %MyReport{} = my_report} <- Reports.update_my_report(my_report, my_report_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", my_report: my_report)
    end
  end

  def delete(conn, %{"id" => id}) do
    my_report = Reports.get_my_report!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %MyReport{}} <- Reports.delete_my_report(my_report, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
