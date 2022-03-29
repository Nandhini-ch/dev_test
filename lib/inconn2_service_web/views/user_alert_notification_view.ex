defmodule Inconn2ServiceWeb.UserAlertNotificationView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.UserAlertNotificationView

  def render("index.json", %{user_alert_notifications: user_alert_notifications}) do
    %{data: render_many(user_alert_notifications, UserAlertNotificationView, "user_alert_notification.json")}
  end

  def render("show.json", %{user_alert_notification: user_alert_notification}) do
    %{data: render_one(user_alert_notification, UserAlertNotificationView, "user_alert_notification.json")}
  end

  def render("user_alert_notification.json", %{user_alert_notification: user_alert_notification}) do
    %{id: user_alert_notification.id,
      alert_id: user_alert_notification.alert_id,
      alert_type: user_alert_notification.alert_type,
      user_id: user_alert_notification.user_id,
      asset_id: user_alert_notification.asset_id}
  end
end
