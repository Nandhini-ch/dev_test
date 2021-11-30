defmodule Inconn2ServiceWeb.AttendanceView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.AttendanceView

  def render("index.json", %{attendances: attendances}) do
    %{data: render_many(attendances, AttendanceView, "attendance.json")}
  end

  def render("show.json", %{attendance: attendance}) do
    %{data: render_one(attendance, AttendanceView, "attendance.json")}
  end

  def render("attendance.json", %{attendance: attendance}) do
    %{id: attendance.id,
      shift_id: attendance.shift_id,
      date: attendance.date,
      attendance_record: attendance.attendance_record}
  end
end
