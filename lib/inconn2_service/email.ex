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

  def send_ticket_complete_email(id, email, prefix) do
    new_email(
      to: email,
      from: "info@inconn.com",
      subject: "Inconn alert and notifications",
      html_body: external_ticket_complete_ack(id, email, prefix),
      text_body: "Hello, Please check your updates in Inconn"
    )
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

  def external_ticket_complete_ack(id, email, prefix) do
    "inc_" <> sub_domain = prefix
    """
      Hi #{email},

      Your Ticket with number #{id} has been resolved

      click here to acknowledge - https://inconn.io/closedReponse?work_request_id=id&sub_domain=#{sub_domain}
      click here to reopen - https://inconn.io/reopeningticket?work_request_id=id&sub_domain=#{sub_domain}

      Thank You,
      Regards

      This is a no-reply email, Please do not repky to this mail
    """
  end
end
