defmodule Inconn2ServiceWeb.AttendanceReferenceView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.AttendanceReferenceView

  def render("index.json", %{attendance_references: attendance_references}) do
    %{data: render_many(attendance_references, AttendanceReferenceView, "attendance_reference.json")}
  end

  def render("show.json", %{attendance_reference: attendance_reference}) do
    %{data: render_one(attendance_reference, AttendanceReferenceView, "attendance_reference.json")}
  end

  def render("attendance_reference.json", %{attendance_reference: attendance_reference}) do
    %{id: attendance_reference.id,
      employee_id: attendance_reference.employee_id,
      reference_image: attendance_reference.reference_image,
      status: attendance_reference.status}
  end
end
