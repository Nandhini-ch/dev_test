defmodule Inconn2ServiceWeb.AttendanceController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Assignment
  alias Inconn2Service.Assignment.Attendance

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    attendances = Assignment.list_attendances(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", attendances: attendances)
  end

  def index_for_user(conn, params) do
    attendances = Assignment.list_attendances_for_employee(conn.assigns.current_user, params, conn.assigns.sub_domain_prefix)
    render(conn, "attendance.json", attendances: attendances)
  end

  def index_for_team(conn, %{"team_id" => team_id}) do
    attendances = Assignment.list_attendances_for_team(team_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", attendances: attendances)
  end

  def create(conn, %{"attendance" => attendance_params, "in_out" => in_out}) do
    IO.inspect(%{"attendance" => attendance_params, "in_out" => in_out})
    with {:ok, %Attendance{} = attendance} <- Assignment.mark_facial_attendance(attendance_params, in_out, conn.assigns.current_user, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.attendance_path(conn, :show, attendance))
      |> render("show.json", attendance: attendance)
    end
  end

  def show(conn, %{"id" => id}) do
    attendance = Assignment.get_attendance!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", attendance: attendance)
  end

  # def update(conn, %{"id" => id, "attendance" => attendance_params}) do
  #   attendance = Assignment.get_attendance!(id, conn.assigns.sub_domain_prefix)

  #   with {:ok, %Attendance{} = attendance} <- Assignment.update_attendance(attendance, attendance_params, conn.assigns.sub_domain_prefix) do
  #     render(conn, "show.json", attendance: attendance)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   attendance = Assignment.get_attendance!(id, conn.assigns.sub_domain_prefix)

  #   with {:ok, %Attendance{}} <- Assignment.delete_attendance(attendance, conn.assigns.sub_domain_prefix) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
