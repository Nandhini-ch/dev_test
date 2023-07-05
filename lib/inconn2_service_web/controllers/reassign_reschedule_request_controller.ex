defmodule Inconn2ServiceWeb.ReassignRescheduleRequestController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Reapportion
  alias Inconn2Service.Reapportion.ReassignRescheduleRequest
  alias Inconn2Service.Workorder.WorkOrder
  alias Inconn2ServiceWeb.WorkOrderView

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    reassign_reschedule_requests = Reapportion.list_reassign_reschedule_requests(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", reassign_reschedule_requests: reassign_reschedule_requests)
  end

  def index_to_be_approved(conn, _params) do
    reassign_reschedule_requests = Reapportion.list_reassign_reschedule_requests_to_be_approved(conn.assigns.sub_domain_prefix, conn.assigns.current_user, conn.query_params)
    render(conn, "index.json", reassign_reschedule_requests: reassign_reschedule_requests)
  end

  def index_pending_approvals(conn, _params) do
    reassign_reschedule_requests = Reapportion.list_reassign_reschedule_requests_pending(conn.assigns.sub_domain_prefix, conn.assigns.current_user, conn.query_params)
    render(conn, "index.json", reassign_reschedule_requests: reassign_reschedule_requests)
  end

  def create(conn, %{"reassign_reschedule_request" => reassign_reschedule_request_params}) do
    case Reapportion.create_reassign_reschedule_request(reassign_reschedule_request_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      {:ok, %ReassignRescheduleRequest{} = reassign_reschedule_request} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.reassign_reschedule_request_path(conn, :show, reassign_reschedule_request))
        |> render("show_without_preload.json", reassign_reschedule_request: reassign_reschedule_request)

      {:ok, %WorkOrder{} = work_order} ->
        conn
        |> put_view(WorkOrderView)
        |> render("work_order.json", work_order: work_order)
    end
  end

  def create_multiple(conn, %{"reassign_reschedule_request" => reassign_reschedule_request_params}) do
    with {:ok, reassign_reschedule_requests} <- Reapportion.create_reassign_reschedule_requests(reassign_reschedule_request_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      conn
      |> put_status(:created)
      |> render("index.json", reassign_reschedule_requests: reassign_reschedule_requests)
    end
  end

  def show(conn, %{"id" => id}) do
    reassign_reschedule_request = Reapportion.get_reassign_reschedule_request!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", reassign_reschedule_request: reassign_reschedule_request)
  end

  def update(conn, %{"id" => id, "reassign_reschedule_request" => reassign_reschedule_request_params}) do
    reassign_reschedule_request = Reapportion.get_reassign_reschedule_request!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %ReassignRescheduleRequest{} = reassign_reschedule_request} <- Reapportion.update_reassign_reschedule_request(reassign_reschedule_request, reassign_reschedule_request_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show_without_preload.json", reassign_reschedule_request: reassign_reschedule_request)
    end
  end

  def reassign_response_for_work_order(conn, %{"id" => id, "reassign_reschedule_request" => reassign_reschedule_request_params}) do
    reassign_reschedule_request = Reapportion.get_reassign_reschedule_request!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %ReassignRescheduleRequest{} = reassign_reschedule_request} <- Reapportion.reassign_work_order_update(reassign_reschedule_request, reassign_reschedule_request_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do   render(conn, "show.json", reassign_reschedule_request: reassign_reschedule_request)
    end
  end

  def reschedule_response_for_work_order(conn, %{"id" => id, "reassign_reschedule_request" => reassign_reschedule_request_params}) do
    reassign_reschedule_request = Reapportion.get_reassign_reschedule_request!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %ReassignRescheduleRequest{} = reassign_reschedule_request} <- Reapportion.reschedule_work_order_update(reassign_reschedule_request, reassign_reschedule_request_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do   render(conn, "show.json", reassign_reschedule_request: reassign_reschedule_request)
    end
  end


  def delete(conn, %{"id" => id}) do
    reassign_reschedule_request = Reapportion.get_reassign_reschedule_request!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %ReassignRescheduleRequest{}} <- Reapportion.delete_reassign_reschedule_request(reassign_reschedule_request, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
