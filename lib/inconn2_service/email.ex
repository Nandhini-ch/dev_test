defmodule Inconn2Service.Email do
  import Bamboo.Email

  def alert_notification_email(user, text) do
    new_email(
      to: user.email,
      from: "info@inconn.com",
      subject: "Inconn alert and notifications",
      html_body: text,
      text_body: "Hello, Please check your updates in Inconn"
    )
  end

  def send_alert_notification_email(user, text) do
    alert_notification_email(user, text) |> Inconn2Service.Mailer.deliver_later!()
  end

  def email_text(user, description) do
    """
      Dear #{user.username},
      This is to notify you that #{description}

      Regards,
      InConn Team


      Note: This is a system generated email, Please do not reply
    """
  end
end
