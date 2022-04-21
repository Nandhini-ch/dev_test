defmodule Inconn2ServiceWeb.AttendanceFailureLogController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Assignment
  alias Inconn2Service.Assignment.AttendanceFailureLog

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    attendance_failure_logs = Assignment.list_attendance_failure_logs(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", attendance_failure_logs: attendance_failure_logs)
  end

  def create(conn, %{"attendance_failure_log" => attendance_failure_log_params}) do
    with {:ok, %AttendanceFailureLog{} = attendance_failure_log} <- Assignment.create_attendance_failure_log(attendance_failure_log_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.attendance_failure_log_path(conn, :show, attendance_failure_log))
      |> render("show.json", attendance_failure_log: attendance_failure_log)
    end
  end

  def show(conn, %{"id" => id}) do
    attendance_failure_log = Assignment.get_attendance_failure_log!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", attendance_failure_log: attendance_failure_log)
  end

  def update(conn, %{"id" => id, "attendance_failure_log" => attendance_failure_log_params}) do
    attendance_failure_log = Assignment.get_attendance_failure_log!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %AttendanceFailureLog{} = attendance_failure_log} <- Assignment.update_attendance_failure_log(attendance_failure_log, attendance_failure_log_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", attendance_failure_log: attendance_failure_log)
    end
  end

  def delete(conn, %{"id" => id}) do
    attendance_failure_log = Assignment.get_attendance_failure_log!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %AttendanceFailureLog{}} <- Assignment.delete_attendance_failure_log(attendance_failure_log, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
