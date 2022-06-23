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

  def send_ticket_complete_email(id, email, name, prefix) do
    new_email(
      to: email,
      from: "info@inconn.com",
      subject: "Inconn alert and notifications",
      html_body: external_ticket_complete_ack(id, name, prefix),
      text_body: "Hello, Please check your updates in Inconn"
    )|> Inconn2Service.Mailer.deliver_now!()
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

  def external_ticket_complete_ack(id, name, prefix) do
    "inc_" <> sub_domain = prefix
    """
      <p> Hi #{name}, </p>

      <p> Your Ticket with number #{id} has been resolved </p>

      <p>
        click here to acknowledge - https://#{sub_domain}.inconn.com:3000/closedresponse?work_request_id=id
      </p>
      <p>
        click here to reopen - https://#{sub_domain}.inconn.com:3000/reopeningticket?work_request_id=id
      </p>

      <p>
        Thank You,
        Regards
      </p>

      <p>This is a system generated email, Please do not reply to this mail</p>

    """
  end
end
