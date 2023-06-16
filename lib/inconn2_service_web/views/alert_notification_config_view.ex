defmodule Inconn2ServiceWeb.AlertNotificationConfigView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{AlertNotificationConfigView, AlertNotificationReserveView, SiteView}

  def render("index.json", %{alert_notification_configs: alert_notification_configs}) do
    %{data: render_many(alert_notification_configs, AlertNotificationConfigView, "alert_notification_config.json")}
  end

  def render("show.json", %{alert_notification_config: alert_notification_config}) do
    %{data: render_one(alert_notification_config, AlertNotificationConfigView, "alert_notification_config.json")}
  end

  def render("alert_notification_config.json", %{alert_notification_config: alert_notification_config}) do
    %{id: alert_notification_config.id,
      alert_notification_reserve_id: alert_notification_config.alert_notification_reserve_id,
      is_escalation_required: alert_notification_config.is_escalation_required,
      escalation_time_in_minutes: alert_notification_config.escalation_time_in_minutes,
      alert_notification_reserve: render_one(alert_notification_config.alert_notification_reserve, AlertNotificationReserveView, "alert_notification_reserve.json"),
      site_id: alert_notification_config.site_id,
      addressed_to_users: alert_notification_config.addressed_to_users,
      escalated_to_users: alert_notification_config.escalated_to_users,
      is_sms_required: alert_notification_config.is_sms_required,
      is_email_required: alert_notification_config.is_email_required,
      site: render_one(alert_notification_config.site, SiteView, "site.json"),
      priority: alert_notification_config.priority}
  end
end
