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
    %{id: alert_notification_reserve.id,
      module: alert_notification_reserve.module,
      description: alert_notification_reserve.description,
      type: alert_notification_reserve.type,
      code: alert_notification_reserve.code}
  end
end
