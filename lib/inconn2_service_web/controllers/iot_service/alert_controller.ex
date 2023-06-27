defmodule Inconn2ServiceWeb.IotService.AlertController do
  use Inconn2ServiceWeb, :controller
  alias Inconn2Service.IotService.Alert

  def send_alert_notifications(conn, %{"alert_notification_params" => alert_notification_params}) do
    Alert.send_alert_and_notification(alert_notification_params, conn.assigns.sub_domain_prefix)
    render(conn, "alert.json", data: %{"result" => "success"})
  end

  def send_sms(conn, %{"sms_params" => sms_params}) do
    Alert.send_sms_iot_alert(sms_params, conn.assigns.sub_domain_prefix)
    render(conn, "alert.json", data: %{"result" => "success"})
  end

  def send_email(conn, %{"email_params" => email_params}) do
    Alert.send_email_iot_alert(email_params)
    render(conn, "alert.json", data: %{"result" => "success"})
  end

  def create_work_order(conn, %{"work_order_params" => work_order_params}) do
    IO.inspect(work_order_params)
    Alert.create_work_order(work_order_params, conn.assigns.sub_domain_prefix) |> IO.inspect()
    render(conn, "alert.json", data: %{"result" => "success"})
  end
end
