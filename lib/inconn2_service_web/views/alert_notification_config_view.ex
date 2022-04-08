defmodule Inconn2ServiceWeb.AlertNotificationConfigView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.AlertNotificationConfigView

  def render("index.json", %{alert_notification_configs: alert_notification_configs}) do
    %{data: render_many(alert_notification_configs, AlertNotificationConfigView, "alert_notification_config.json")}
  end

  def render("show.json", %{alert_notification_config: alert_notification_config}) do
    %{data: render_one(alert_notification_config, AlertNotificationConfigView, "alert_notification_config.json")}
  end

  def render("alert_notification_config.json", %{alert_notification_config: alert_notification_config}) do
    %{id: alert_notification_config.id,
      alert_notification_reserve_id: alert_notification_config.alert_notification_reserve_id,
      addressed_to_user_ids: alert_notification_config.addressed_to_user_ids}
  end
end
