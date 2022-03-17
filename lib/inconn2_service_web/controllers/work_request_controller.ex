defmodule Inconn2ServiceWeb.WorkRequestController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.WorkRequest

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    work_requests = Ticket.list_work_requests(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", work_requests: work_requests)
  end

  def index_for_user_by_qr(conn, %{"qr_string" => qr_string}) do
    work_requests = Ticket.list_work_requests_for_user_by_qr(qr_string, conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", work_requests: work_requests)
  end

  def index_for_actions(conn, _) do
    work_requests = Ticket.list_work_requests_for_actions(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index_for_actions.json", work_requests: work_requests)
  end

  def index_for_raised_user(conn, _) do
    work_requests = Ticket.list_work_requests_for_raised_user(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", work_requests: work_requests)
  end

  def index_for_assigned_user(conn, _) do
    work_requests = Ticket.list_work_requests_for_assigned_user(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", work_requests: work_requests)
  end

  def index_approval_required(conn, _params) do
    work_requests = Ticket.list_work_requests_for_approval(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", work_requests: work_requests)
  end

  def index_tickets_of_helpdesk_user(conn, _params) do
    work_requests = Ticket.list_work_requests_for_helpdesk_user(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", work_requests: work_requests)
  end

  def index_for_acknowledgement(conn, _) do
    work_requests = Ticket.list_work_requests_acknowledgement(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
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

  def update(conn, %{"id" => id, "work_request" => work_request_params}) do
    work_request = Ticket.get_work_request!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkRequest{} = work_request} <- Ticket.update_work_request(work_request, work_request_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", work_request: work_request)
    end
  end

  def update_multiple(conn, %{"work_request_changes" => work_request_changes}) do
    work_requests = Ticket.update_work_requests(work_request_changes, conn.assigns.sub_domain_prefix, conn.assigns.current_user)
    render(conn, "index.json", work_requests: work_requests)
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
