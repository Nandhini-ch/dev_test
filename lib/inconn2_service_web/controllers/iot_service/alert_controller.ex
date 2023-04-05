defmodule Inconn2ServiceWeb.IotService.AlertController do
  use Inconn2ServiceWeb, :controller
  alias Inconn2Service.Email

  def send_alert(conn, %{"alert_params" => _alert_params}) do
    render(conn, "alert.json", data: %{"result" => "success"})
  end

  def send_sms(conn, %{"sms_params" => _sms_params}) do
    render(conn, "alert.json", data: [])
  end

  def send_email(conn, %{"params" => params}) do
    Email.send_email_iot_alert(params)
    render(conn, "alert.json", data: %{"result" => "success"})
  end

  def create_work_order(conn, %{"work_order_params" => _work_order_params}) do
    render(conn, "alert.json", data: [])
  end
end
