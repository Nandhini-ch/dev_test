defmodule Inconn2ServiceWeb.WorkRequestController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.WorkRequest

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    work_requests = Ticket.list_work_requests(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", work_requests: work_requests)
  end

  def create(conn, %{"work_request" => work_request_params}) do
    with {:ok, %WorkRequest{} = work_request} <- Ticket.create_work_request(work_request_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.work_request_path(conn, :show, work_request))
      |> render("show.json", work_request: work_request)
    end
  end

  def show(conn, %{"id" => id}) do
    work_request = Ticket.get_work_request!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", work_request: work_request)
  end

  def update(conn, %{"id" => id} = work_request_params) do
    work_request = Ticket.get_work_request!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkRequest{} = work_request} <- Ticket.update_work_request(work_request, work_request_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", work_request: work_request)
    end
  end

  def delete(conn, %{"id" => id}) do
    work_request = Ticket.get_work_request!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkRequest{}} <- Ticket.delete_work_request(work_request, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

  def get_attachment(conn, %{"work_request_id" => work_request_id}) do
    work_request = Ticket.get_work_request!(work_request_id, conn.assigns.sub_domain_prefix)
    case work_request.attachment do
      nil ->
        {:error, :not_found}
      binary ->
        conn
        |> put_resp_content_type(work_request.attachment_type)
        |> send_resp(200, binary)
    end
  end
end
