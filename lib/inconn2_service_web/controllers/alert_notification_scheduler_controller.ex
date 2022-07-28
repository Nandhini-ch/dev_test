defmodule Inconn2ServiceWeb.AlertNotificationSchedulerController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Common
  alias Inconn2Service.Common.AlertNotificationScheduler

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    alert_notification_schedulers = Common.list_alert_notification_schedulers()
    render(conn, "index.json", alert_notification_schedulers: alert_notification_schedulers)
  end

  def create(conn, %{"alert_notification_scheduler" => alert_notification_scheduler_params}) do
    with {:ok, %AlertNotificationScheduler{} = alert_notification_scheduler} <- Common.create_alert_notification_scheduler(alert_notification_scheduler_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.alert_notification_scheduler_path(conn, :show, alert_notification_scheduler))
      |> render("show.json", alert_notification_scheduler: alert_notification_scheduler)
    end
  end

  def show(conn, %{"id" => id}) do
    alert_notification_scheduler = Common.get_alert_notification_scheduler!(id)
    render(conn, "show.json", alert_notification_scheduler: alert_notification_scheduler)
  end

  def update(conn, %{"id" => id, "alert_notification_scheduler" => alert_notification_scheduler_params}) do
    alert_notification_scheduler = Common.get_alert_notification_scheduler!(id)

    with {:ok, %AlertNotificationScheduler{} = alert_notification_scheduler} <- Common.update_alert_notification_scheduler(alert_notification_scheduler, alert_notification_scheduler_params) do
      render(conn, "show.json", alert_notification_scheduler: alert_notification_scheduler)
    end
  end

  def delete(conn, %{"id" => id}) do
    alert_notification_scheduler = Common.get_alert_notification_scheduler!(id)

    with {:ok, %AlertNotificationScheduler{}} <- Common.delete_alert_notification_scheduler(alert_notification_scheduler) do
      send_resp(conn, :no_content, "")
    end
  end
end
