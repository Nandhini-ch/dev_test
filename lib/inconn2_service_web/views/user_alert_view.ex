defmodule Inconn2ServiceWeb.UserAlertView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.UserAlertView

  def render("index.json", %{user_alerts: user_alerts}) do
    %{data: render_many(user_alerts, UserAlertView, "user_alert.json")}
  end

  def render("show.json", %{user_alert: user_alert}) do
    %{data: render_one(user_alert, UserAlertView, "user_alert.json")}
  end

  def render("user_alert.json", %{user_alert: user_alert}) do
    %{id: user_alert.id,
      alert_id: user_alert.alert_id,
      alert_type: user_alert.alert_type,
      user_id: user_alert.user_id,
      asset_id: user_alert.asset_id}
  end
end
