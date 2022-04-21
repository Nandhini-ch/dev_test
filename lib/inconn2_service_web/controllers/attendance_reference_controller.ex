defmodule Inconn2ServiceWeb.AttendanceReferenceController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Assignment
  alias Inconn2Service.Assignment.AttendanceReference

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    attendance_references = Assignment.list_attendance_references(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", attendance_references: attendance_references)
  end

  def create(conn, %{"attendance_reference" => attendance_reference_params}) do
    with {:ok, %AttendanceReference{} = attendance_reference} <- Assignment.create_attendance_reference(attendance_reference_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.attendance_reference_path(conn, :show, attendance_reference))
      |> render("show.json", attendance_reference: attendance_reference)
    end
  end

  def show(conn, %{"id" => id}) do
    attendance_reference = Assignment.get_attendance_reference!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", attendance_reference: attendance_reference)
  end

  def update(conn, %{"id" => id, "attendance_reference" => attendance_reference_params}) do
    attendance_reference = Assignment.get_attendance_reference!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %AttendanceReference{} = attendance_reference} <- Assignment.update_attendance_reference(attendance_reference, attendance_reference_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", attendance_reference: attendance_reference)
    end
  end

  def delete(conn, %{"id" => id}) do
    attendance_reference = Assignment.get_attendance_reference!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %AttendanceReference{}} <- Assignment.delete_attendance_reference(attendance_reference, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
