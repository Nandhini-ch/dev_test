defmodule Inconn2ServiceWeb.ExternalTicketController do
  use Inconn2ServiceWeb, :controller
  alias Inconn2Service.{AssetConfig, ExternalTicket}

#QR code

def get_equipment_ticket_qr(conn, %{"id" => id}) do
  equipment = AssetConfig.get_equipment!(id, conn.assigns.sub_domain_prefix)
  png = ExternalTicket.generate_equipment_ticket_qr(equipment, conn.assigns.sub_domain_prefix)
  conn
    |> put_resp_content_type("image/jpeg")
    |> send_resp(200, png)
end

def get_location_ticket_qr(conn, %{"id" => id}) do
  location = AssetConfig.get_location!(id, conn.assigns.sub_domain_prefix)
  png = ExternalTicket.generate_location_ticket_qr(location, conn.assigns.sub_domain_prefix)
  conn
    |> put_resp_content_type("image/jpeg")
    |> send_resp(200, png)
end

def get_equipment_ticket_qr_code_as_pdf(conn, %{"id" => id}) do
  equipment = AssetConfig.get_equipment!(id, conn.assigns.sub_domain_prefix)
  {name, pdf} = ExternalTicket.generate_equipment_ticket_qr_as_pdf(equipment, conn.assigns.sub_domain_prefix)
  conn
  |> put_resp_content_type("application/pdf")
  |> put_resp_header("content-disposition", "attachment; filename=\"#{name}.pdf\"")
  |> send_resp(200, pdf)
end

def get_location_ticket_qr_code_as_pdf(conn, %{"id" => id}) do
  location = AssetConfig.get_location!(id, conn.assigns.sub_domain_prefix)
  {name, pdf} = ExternalTicket.generate_location_ticket_qr_as_pdf(location, conn.assigns.sub_domain_prefix)
  conn
  |> put_resp_content_type("application/pdf")
  |> put_resp_header("content-disposition", "attachment; filename=\"#{name}.pdf\"")
  |> send_resp(200, pdf)
end
#Ticket


end
