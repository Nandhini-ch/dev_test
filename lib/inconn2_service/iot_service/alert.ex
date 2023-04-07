defmodule Inconn2Service.IotService.Alert do
  alias Inconn2Service.Workorder
  alias Inconn2Service.Prompt
  alias Inconn2Service.Communication.EmailSender

  def send_email_iot_alert(params) do
    EmailSender.send_email(params["recipients"], params["subject_string"], params["body_string"])
  end

  def send_alert_and_notification(params, prefix) do
    Enum.map(params, fn a -> Prompt.create_user_alert_notification(a, prefix) end)
  end

  def create_work_order(params, prefix) do
   Workorder.create_work_order(params, prefix)
  end

end
