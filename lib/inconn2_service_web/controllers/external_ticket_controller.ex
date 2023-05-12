defmodule Inconn2ServiceWeb.ExternalTicketController do
  use Inconn2ServiceWeb, :controller
  alias Inconn2Service.Ticket.WorkRequest
  alias Inconn2Service.{AssetConfig, ExternalTicket, Ticket}

  action_fallback Inconn2ServiceWeb.FallbackController

#QR code

def get_equipment_ticket_qr(conn, %{"id" => id}) do
  equipment = AssetConfig.get_equipment!(id, conn.assigns.sub_domain_prefix)
  {name, png} = ExternalTicket.generate_equipment_ticket_qr(equipment, conn.assigns.sub_domain_prefix)
  conn
    |> put_resp_content_type("image/jpeg")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{name}.jpeg\"")
    |> send_resp(200, png)
end

def get_location_ticket_qr(conn, %{"id" => id}) do
  location = AssetConfig.get_location!(id, conn.assigns.sub_domain_prefix)
  {name, png} = ExternalTicket.generate_location_ticket_qr(location, conn.assigns.sub_domain_prefix)
  conn
    |> put_resp_content_type("image/jpeg")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{name}.jpeg\"")
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

def index_categories(conn, _params) do
    workrequest_categories = Ticket.list_workrequest_categories(conn.assigns.sub_domain_prefix)
    render(conn, "index_categories.json", workrequest_categories: workrequest_categories)
end

def index_subcategories_for_category(conn, %{"workrequest_category_id" => workrequest_category_id}) do
    workrequest_subcategories = Ticket.list_workrequest_subcategories_for_category(workrequest_category_id, conn.assigns.sub_domain_prefix)
    render(conn, "index_subcategories.json", workrequest_subcategories: workrequest_subcategories)
end

def create(conn, %{"work_request" => work_request_params}) do
  with {:ok, %WorkRequest{} = work_request} <- ExternalTicket.create_external_work_request(work_request_params, conn.assigns.sub_domain_prefix) do
    conn
    |> put_status(:created)
    |> put_resp_header("location", Routes.work_request_path(conn, :show, work_request))
    |> render("show.json", work_request: work_request)
  end
end

def show(conn, %{"id" => id}) do
  work_request = ExternalTicket.get_work_request!(id, conn.assigns.sub_domain_prefix)
  render(conn, "show.json", work_request: work_request)
end

def update(conn, %{"id" => id, "work_request" => work_request_params}) do
  work_request = Ticket.get_work_request!(id, conn.assigns.sub_domain_prefix)

  with {:ok, %WorkRequest{} = work_request} <- ExternalTicket.update_external_work_request(work_request, work_request_params, conn.assigns.sub_domain_prefix) do
    render(conn, "show.json", work_request: work_request)
  end
end

end
