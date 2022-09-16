defmodule Inconn2ServiceWeb.AttendanceView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{AttendanceView, EmployeeView, ShiftView}

  def render("index.json", %{attendances: attendances}) do
    %{data: render_many(attendances, AttendanceView, "attendance.json")}
  end

  def render("show.json", %{attendance: attendance}) do
    %{data: render_one(attendance, AttendanceView, "attendance.json")}
  end

  def render("attendance.json", %{attendance: attendance}) do
    %{id: attendance.id,
      in_time: attendance.in_time,
      out_time: attendance.out_time,
      latitude: attendance.latitude,
      longitude: attendance.longitude,
      site_id: attendance.site_id,
      shift_id: attendance.shift_id,
      employee_id: attendance.employee_id,
      shift: render_one(attendance.shift, ShiftView, "shift.json"),
      employee: render_one(attendance.employee, EmployeeView, "employee_without_org_unit.json")
    }
  end
end
