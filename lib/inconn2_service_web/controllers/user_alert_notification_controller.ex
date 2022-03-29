defmodule Inconn2ServiceWeb.UserAlertNotificationController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Prompt
  alias Inconn2Service.Prompt.UserAlertNotification

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    user_alert_notifications = Prompt.list_user_alert_notifications(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", user_alert_notifications: user_alert_notifications)
  end

  def create(conn, %{"user_alert_notification" => user_alert_notification_params}) do
    with {:ok, %UserAlertNotification{} = user_alert_notification} <- Prompt.create_user_alert_notification(user_alert_notification_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_alert_path(conn, :show, user_alert_notification))
      |> render("show.json", user_alert_notification: user_alert_notification)
    end
  end

  def show(conn, %{"id" => id}) do
    user_alert_notification = Prompt.get_user_alert_notification!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", user_alert_notification: user_alert_notification)
  end

  def update(conn, %{"id" => id, "user_alert_notification" => user_alert_notification_params}) do
    user_alert_notification = Prompt.get_user_alert_notification!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %UserAlertNotification{} = user_alert_notification} <- Prompt.update_user_alert_notification(user_alert_notification, user_alert_notification_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", user_alert_notification: user_alert_notification)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_alert_notification = Prompt.get_user_alert_notification!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %UserAlertNotification{}} <- Prompt.delete_user_alert_notification(user_alert_notification, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
