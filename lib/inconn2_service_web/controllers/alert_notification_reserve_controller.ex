defmodule Inconn2ServiceWeb.AlertNotificationReserveController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Common
  alias Inconn2Service.Common.AlertNotificationReserve

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    alert_notification_reserves = Common.list_alert_notification_reserves()
    render(conn, "index.json", alert_notification_reserves: alert_notification_reserves)
  end

  def create(conn, %{"alert_notification_reserve" => alert_notification_reserve_params}) do
    with {:ok, %AlertNotificationReserve{} = alert_notification_reserve} <- Common.create_alert_notification_reserve(alert_notification_reserve_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.alert_notification_reserve_path(conn, :show, alert_notification_reserve))
      |> render("show.json", alert_notification_reserve: alert_notification_reserve)
    end
  end

  def show(conn, %{"id" => id}) do
    alert_notification_reserve = Common.get_alert_notification_reserve!(id)
    render(conn, "show.json", alert_notification_reserve: alert_notification_reserve)
  end

  def update(conn, %{"id" => id, "alert_notification_reserve" => alert_notification_reserve_params}) do
    alert_notification_reserve = Common.get_alert_notification_reserve!(id)

    with {:ok, %AlertNotificationReserve{} = alert_notification_reserve} <- Common.update_alert_notification_reserve(alert_notification_reserve, alert_notification_reserve_params) do
      render(conn, "show.json", alert_notification_reserve: alert_notification_reserve)
    end
  end

  def delete(conn, %{"id" => id}) do
    alert_notification_reserve = Common.get_alert_notification_reserve!(id)

    with {:ok, %AlertNotificationReserve{}} <- Common.delete_alert_notification_reserve(alert_notification_reserve) do
      send_resp(conn, :no_content, "")
    end
  end
end
