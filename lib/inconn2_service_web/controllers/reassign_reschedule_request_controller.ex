defmodule Inconn2ServiceWeb.ReassignRescheduleRequestController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Reapportion
  alias Inconn2Service.Reapportion.ReassignRescheduleRequest

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    reassign_reschedule_requests = Reapportion.list_reassign_reschedule_requests(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", reassign_reschedule_requests: reassign_reschedule_requests)
  end

  def create(conn, %{"reassign_reschedule_request" => reassign_reschedule_request_params}) do
    with {:ok, %ReassignRescheduleRequest{} = reassign_reschedule_request} <- Reapportion.create_reassign_reschedule_request(reassign_reschedule_request_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.reassign_reschedule_request_path(conn, :show, reassign_reschedule_request))
      |> render("show.json", reassign_reschedule_request: reassign_reschedule_request)
    end
  end

  def show(conn, %{"id" => id}) do
    reassign_reschedule_request = Reapportion.get_reassign_reschedule_request!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", reassign_reschedule_request: reassign_reschedule_request)
  end

  def update(conn, %{"id" => id, "reassign_reschedule_request" => reassign_reschedule_request_params}) do
    reassign_reschedule_request = Reapportion.get_reassign_reschedule_request!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %ReassignRescheduleRequest{} = reassign_reschedule_request} <- Reapportion.update_reassign_reschedule_request(reassign_reschedule_request, reassign_reschedule_request_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", reassign_reschedule_request: reassign_reschedule_request)
    end
  end

  def respond_to_reassign_request(conn, %{"id" => id, "reassign_reschedule_request" => reassign_reschedule_request_params}) do
    reassign_reschedule_request = Reapportion.get_reassign_reschedule_request!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %ReassignRescheduleRequest{} = reassign_reschedule_request} <- Reapportion.respond_to_reassign_work_order(reassign_reschedule_request, reassign_reschedule_request_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", reassign_reschedule_request: reassign_reschedule_request)
    end
  end


  def delete(conn, %{"id" => id}) do
    reassign_reschedule_request = Reapportion.get_reassign_reschedule_request!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %ReassignRescheduleRequest{}} <- Reapportion.delete_reassign_reschedule_request(reassign_reschedule_request, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
