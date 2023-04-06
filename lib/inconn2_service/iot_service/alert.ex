defmodule Inconn2Service.IotService.Alert do
  alias Inconn2Service.Communication.EmailSender

  def send_email_iot_alert(params) do
    EmailSender.send_email(params["recipients"], params["subject_string"], params["body_string"])
  end
end
