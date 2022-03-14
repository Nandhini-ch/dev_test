defmodule Inconn2ServiceWeb.ApprovalController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.Approval

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    approvals = Ticket.list_approvals(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", approvals: approvals)
  end

  def approvals_for_work_request(conn, %{"work_request_id" => work_request_id}) do
    approvals = Ticket.list_approvals_for_work_order(work_request_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", approvals: approvals)
  end

  def create_multiple_approval(conn, %{"work_requests_params" => work_requests_params}) do
    result = Ticket.create_multiple_approval(work_requests_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user)
    render(conn, "multiple_create.json", result: result)
  end

  def create(conn, %{"approval" => approval_params}) do
    with {:ok, %Approval{} = approval} <- Ticket.create_approval(approval_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.approval_path(conn, :show, approval))
      |> render("show.json", approval: approval)
    end
  end

  def show(conn, %{"id" => id}) do
    approval = Ticket.get_approval!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", approval: approval)
  end

  def update(conn, %{"id" => id, "approval" => approval_params}) do
    approval = Ticket.get_approval!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Approval{} = approval} <- Ticket.update_approval(approval, approval_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", approval: approval)
    end
  end

  def delete(conn, %{"id" => id}) do
    approval = Ticket.get_approval!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Approval{}} <- Ticket.delete_approval(approval, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
