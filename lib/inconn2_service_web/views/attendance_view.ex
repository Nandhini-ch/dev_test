defmodule Inconn2ServiceWeb.AttendanceView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{AttendanceView, EmployeeView}

  def render("index.json", %{attendances: attendances}) do
    %{data: render_many(attendances, AttendanceView, "attendance.json")}
  end

  def render("show.json", %{attendance: attendance}) do
    %{data: render_one(attendance, AttendanceView, "attendance.json")}
  end

  def render("attendance.json", %{attendance: attendance}) do
    %{id: attendance.id,
      date_time: attendance.date_time,
      latitude: attendance.latitude,
      longitude: attendance.longitude,
      site_id: attendance.site_id,
      employee_id: attendance.employee_id,
      employee: render_one(attendance.employee, EmployeeView, "employee_without_org_unit.json")
    }
  end
end
