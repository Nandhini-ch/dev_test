defmodule Inconn2Service.Email do
  import Swoosh.Email
  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Communication.EmailSender

  def send_alert_notification_email(recipient, username, type, message) do
    subject_string =
            case type do
              "al" -> "Alert From Inconn"
              "nt" -> "Notification From Inconn"
            end

    type_string =
          case type do
            "al" -> "alert"
            "nt" -> "notification"
          end

    body_string = ~s(
      Dear #{username},

        This is to #{type_string} you that #{message}

      Regards,
      InConn team

      Note:	This is a system generated email from an unmonitored mailbox. Kindly do not reply. To contact us, kindly  call xxxxxxxxxx or email to us at xxxxxx@xxx.xxx
    )
    EmailSender.send_email(recipient, subject_string, body_string)
  end

  def send_ticket_complete_email(id, email, name, remarks, date_time, prefix) do
    new()
    |> to({name, email})
    |> from({"Inconn Support", "info@inconn.com"})
    |> subject("Update on Ticket #{id}")
    |> text_body(external_ticket_complete_ack(id, name, remarks, date_time, prefix))
    |> Inconn2Service.Mailer.deliver!()
  end

  def send_ticket_reg_email(id, email, name) do
    new()
    |> to({name, email})
    |> from({"Inconn Support", "info@inconn.com"})
    |> subject("Update on Ticket #{id}")
    |> text_body(external_ticket_reg_ack(id, name))
    |> Inconn2Service.Mailer.deliver!()
  end


  def send_alert_email(user, description) do
    new()
    |> to({user.employee.first_name, user.email})
    |> from({"Inconn Support", "info@inconn.com"})
    |> subject("Inconn Alerts and Notifications")
    |> text_body(alert_text(user, description))
    |> Inconn2Service.Mailer.deliver!()
  end

  def alert_text(user, description) do
    """
      Hi #{user.employee.first_name} #{user.employee.last_name}

      #{description}

      Thank You.

      Regards,
      Inconn Team

      NOTE: This is a system generated email, Please do not reply to this mail
    """
  end

  def external_ticket_reg_ack(id, _name) do
    """
       Dear Customer,

       Thank you for using InConn
       Your concern is registered with ticket number #{id}
       Kindly check your email for updates.

        Thank You,
        Regards
        Inconn Team

        Kindly note that this is a system generated E-mail and this ID is not monitored, Please do not reply
    """
  end

  def external_ticket_complete_ack(id, _name, remarks, date_time, prefix) do
    "inc_" <> sub_domain = prefix
    """
       Dear Customer,

       Your Ticket with number #{id} has been resolved at #{date_time} and with below remarks

       #{remarks}

        Please click here to acknowledge your issue resolution -
        #{get_frontend_url(sub_domain)}/closedresponse?work_request_id=#{id}

        If you are not happy with the solution offered, please click here to reopen -
        #{get_frontend_url(sub_domain)}/ticketreopening?ticketId=#{id}

        Thank You,
        Regards
        Inconn Team

        Kindly note that this is a system generated E-mail and this ID is not monitored, Please do not reply
    """
  end

end
