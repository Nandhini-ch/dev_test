defmodule Inconn2ServiceWeb.ManualAttendanceController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Assignment
  alias Inconn2Service.Assignment.ManualAttendance

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    manual_attendances = Assignment.list_manual_attendances(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", manual_attendances: manual_attendances)
  end

  def create(conn, %{"manual_attendance" => manual_attendance_params}) do
    with {:ok, %ManualAttendance{} = manual_attendance} <- Assignment.create_manual_attendance(manual_attendance_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.manual_attendance_path(conn, :show, manual_attendance))
      |> render("show.json", manual_attendance: manual_attendance)
    end
  end

  def show(conn, %{"id" => id}) do
    manual_attendance = Assignment.get_manual_attendance!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", manual_attendance: manual_attendance)
  end

  def update(conn, %{"id" => id, "manual_attendance" => manual_attendance_params}) do
    manual_attendance = Assignment.get_manual_attendance!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %ManualAttendance{} = manual_attendance} <- Assignment.update_manual_attendance(manual_attendance, manual_attendance_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", manual_attendance: manual_attendance)
    end
  end

  def delete(conn, %{"id" => id}) do
    manual_attendance = Assignment.get_manual_attendance!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %ManualAttendance{}} <- Assignment.delete_manual_attendance(manual_attendance, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
