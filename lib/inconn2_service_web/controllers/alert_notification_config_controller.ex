defmodule Inconn2ServiceWeb.AlertNotificationConfigController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Prompt
  alias Inconn2Service.Prompt.AlertNotificationConfig

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    alert_notification_configs = Prompt.list_alert_notification_configs(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", alert_notification_configs: alert_notification_configs)
  end

  def create(conn, %{"alert_notification_config" => alert_notification_config_params}) do
    with {:ok, %AlertNotificationConfig{} = alert_notification_config} <- Prompt.create_alert_notification_config(alert_notification_config_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.alert_notification_config_path(conn, :show, alert_notification_config))
      |> render("show.json", alert_notification_config: alert_notification_config)
    end
  end

  def show(conn, %{"id" => id}) do
    alert_notification_config = Prompt.get_alert_notification_config!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", alert_notification_config: alert_notification_config)
  end

  def update(conn, %{"id" => id, "alert_notification_config" => alert_notification_config_params}) do
    alert_notification_config = Prompt.get_alert_notification_config!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %AlertNotificationConfig{} = alert_notification_config} <- Prompt.update_alert_notification_config(alert_notification_config, alert_notification_config_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", alert_notification_config: alert_notification_config)
    end
  end

  def delete(conn, %{"id" => id}) do
    alert_notification_config = Prompt.get_alert_notification_config!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %AlertNotificationConfig{}} <- Prompt.delete_alert_notification_config(alert_notification_config, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
