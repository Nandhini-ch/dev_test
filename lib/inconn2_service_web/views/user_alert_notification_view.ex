defmodule Inconn2ServiceWeb.UserAlertNotificationView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{UserAlertNotificationView, AlertNotificationReserveView}

  def render("index.json", %{user_alert_notifications: user_alert_notifications}) do
    %{data: render_many(user_alert_notifications, UserAlertNotificationView, "user_alert_notification.json")}
  end

  def render("show.json", %{user_alert_notification: user_alert_notification}) do
    %{data: render_one(user_alert_notification, UserAlertNotificationView, "user_alert_notification.json")}
  end

  def render("user_alert_notification.json", %{user_alert_notification: user_alert_notification}) do
    %{id: user_alert_notification.id,
      alert_notification_id: user_alert_notification.alert_notification_id,
      # alert_notification: render_one(user_alert_notification.alert_notification, AlertNotificationReserveView, "alert_notification_reserve.json"),
      type: user_alert_notification.type,
      user_id: user_alert_notification.user_id,
      description: user_alert_notification.description,
      acknowledged_date_time: user_alert_notification.acknowledged_date_time,
      action_taken: user_alert_notification.action_taken,
      escalation: user_alert_notification.escalation}
  end

  def render("success.json", %{success: success}) do
    %{
      data: success
    }
  end
end
