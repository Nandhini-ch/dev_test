defmodule Inconn2Service.Email do
  import Swoosh.Email

  def send_ticket_complete_email(id, email, name, prefix) do
    new()
    |> to({name, email})
    |> from({"Inconn Support", "info@inconn.com"})
    |> subject("Update on Ticket #{id}")
    |> text_body(external_ticket_complete_ack(id, name, prefix))
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

  def external_ticket_reg_ack(id, name) do
    """
       Hi #{name},

       Your Ticket with number #{id} has been registered

        Thank You,
        Regards


      NOTE: This is a system generated email, Please do not reply to this mail

    """
  end

  def external_ticket_complete_ack(id, name, prefix) do
    "inc_" <> sub_domain = prefix
    """
       Hi #{name},

       Your Ticket with number #{id} has been resolved


        click here to acknowledge -
        https://#{sub_domain}.inconn.com:3000/closedresponse?work_request_id=#{id}

        click here to reopen -
        https://#{sub_domain}.inconn.com:3000/ticketreopening?ticketId=#{id}

        Thank You,
        Regards


      NOTE: This is a system generated email, Please do not reply to this mail

    """
  end
end
