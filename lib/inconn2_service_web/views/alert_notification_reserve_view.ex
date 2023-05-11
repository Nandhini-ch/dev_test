defmodule Inconn2ServiceWeb.AlertNotificationReserveView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.AlertNotificationReserveView

  def render("index.json", %{alert_notification_reserves: alert_notification_reserves}) do
    %{data: render_many(alert_notification_reserves, AlertNotificationReserveView, "alert_notification_reserve.json")}
  end

  def render("show.json", %{alert_notification_reserve: alert_notification_reserve}) do
    %{data: render_one(alert_notification_reserve, AlertNotificationReserveView, "alert_notification_reserve.json")}
  end

  def render("alert_notification_reserve.json", %{alert_notification_reserve: alert_notification_reserve}) do
    %{
      id: alert_notification_reserve.id,
      module: alert_notification_reserve.module,
      description: alert_notification_reserve.description,
      type: alert_notification_reserve.type,
      code: alert_notification_reserve.code,
      sms_code: alert_notification_reserve.sms_code,
      text_template: alert_notification_reserve.text_template,
      is_sms_required: alert_notification_reserve.is_sms_required,
      is_email_required: alert_notification_reserve.is_email_required,
      is_escalation_required: alert_notification_reserve.is_escalation_required,
      escalation_time_in_minutes: alert_notification_reserve.escalation_time_in_minutes
    }
  end

  def render("success.json", %{alert_notification_reserve: alert_notification_reserve}) do
    %{
      data: alert_notification_reserve
    }
  end
end
