defmodule Inconn2ServiceWeb.ManualAttendanceView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.ManualAttendanceView

  def render("index.json", %{manual_attendances: manual_attendances}) do
    %{data: render_many(manual_attendances, ManualAttendanceView, "manual_attendance.json")}
  end

  def render("show.json", %{manual_attendance: manual_attendance}) do
    %{data: render_one(manual_attendance, ManualAttendanceView, "manual_attendance.json")}
  end

  def render("manual_attendance.json", %{manual_attendance: manual_attendance}) do
    %{id: manual_attendance.id,
      employee_id: manual_attendance.employee_id,
      shift_id: manual_attendance.shift_id,
      in_time: manual_attendance.in_time,
      out_time: manual_attendance.out_time,
      worked_hours_in_minutes: manual_attendance.worked_hours_in_minutes,
      is_overtime: manual_attendance.is_overtime,
      overtime_hours_in_minutes: manual_attendance.overtime_hours_in_minutes,
      in_time_marked_by: manual_attendance.in_time_marked_by,
      out_time_marked_by: manual_attendance.out_time_marked_by,
      status: manual_attendance.status}
  end
end
