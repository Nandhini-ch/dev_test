defmodule Inconn2ServiceWeb.SendSmsView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.SendSmsView

  def render("index.json", %{send_sms: send_sms}) do
    %{data: render_many(send_sms, SendSmsView, "send_sms.json")}
  end

  def render("show.json", %{send_sms: send_sms}) do
    %{data: render_one(send_sms, SendSmsView, "send_sms.json")}
  end

  def render("send_sms.json", %{send_sms: send_sms}) do
    %{id: send_sms.id,
      user_id: send_sms.user_id,
      mobile_no: send_sms.mobile_no,
      template_id: send_sms.template_id,
      message: send_sms.message,
      job_id: send_sms.job_id,
      message_id: send_sms.message_id,
      error_code: send_sms.error_code,
      error_message: send_sms.error_message,
      delivery_status: send_sms.delivery_status,
      date_time: send_sms.date_time
    }
  end
end
