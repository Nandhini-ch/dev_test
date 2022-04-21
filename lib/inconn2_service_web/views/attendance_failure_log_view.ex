defmodule Inconn2ServiceWeb.AttendanceFailureLogView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.AttendanceFailureLogView

  def render("index.json", %{attendance_failure_logs: attendance_failure_logs}) do
    %{data: render_many(attendance_failure_logs, AttendanceFailureLogView, "attendance_failure_log.json")}
  end

  def render("show.json", %{attendance_failure_log: attendance_failure_log}) do
    %{data: render_one(attendance_failure_log, AttendanceFailureLogView, "attendance_failure_log.json")}
  end

  def render("attendance_failure_log.json", %{attendance_failure_log: attendance_failure_log}) do
    %{id: attendance_failure_log.id,
      employee_id: attendance_failure_log.employee_id,
      failure_image: attendance_failure_log.failure_image,
      date_time: attendance_failure_log.date_time}
  end
end
