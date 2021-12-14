defmodule Inconn2ServiceWeb.AttendanceView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{AttendanceView, ShiftView}

  def render("index.json", %{attendances: attendances}) do
    %{data: render_many(attendances, AttendanceView, "attendance.json")}
  end

  def render("show.json", %{attendance: attendance}) do
    %{data: render_one(attendance, AttendanceView, "attendance.json")}
  end

  def render("attendance.json", %{attendance: attendance}) do
    %{id: attendance.id,
      shift: render_one(attendance.shift, ShiftView, "shift.json"),
      date: attendance.date,
      attendance_record: attendance.attendance_record}
  end
end
