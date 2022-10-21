defmodule Inconn2ServiceWeb.AlertNotificationSchedulerView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.AlertNotificationSchedulerView

  def render("index.json", %{alert_notification_schedulers: alert_notification_schedulers}) do
    %{data: render_many(alert_notification_schedulers, AlertNotificationSchedulerView, "alert_notification_scheduler.json")}
  end

  def render("show.json", %{alert_notification_scheduler: alert_notification_scheduler}) do
    %{data: render_one(alert_notification_scheduler, AlertNotificationSchedulerView, "alert_notification_scheduler.json")}
  end

  def render("alert_notification_scheduler.json", %{alert_notification_scheduler: alert_notification_scheduler}) do
    %{id: alert_notification_scheduler.id,
      alert_identifier_date_time: alert_notification_scheduler.alert_identifier_date_time,
      alert_code: alert_notification_scheduler.alert_code,
      site_id: alert_notification_scheduler.site_id,
      escalation_at_date_time: alert_notification_scheduler.escalation_at_date_time}
  end
end
