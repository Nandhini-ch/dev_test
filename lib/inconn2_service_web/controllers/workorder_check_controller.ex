defmodule Inconn2ServiceWeb.WorkorderCheckController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkorderCheck

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    workorder_checks = Workorder.list_workorder_checks(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", workorder_checks: workorder_checks)
  end

  def index_workorder_check_by_type(conn, %{"work_order_id" => work_order_id, "check_type" => check_type}) do
    workorder_checks = Workorder.list_workorder_checks_by_type(work_order_id, check_type, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", workorder_checks: workorder_checks)
  end

  def create(conn, %{"workorder_check" => workorder_check_params}) do
    with {:ok, %WorkorderCheck{} = workorder_check} <- Workorder.create_workorder_check(workorder_check_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.workorder_check_path(conn, :show, workorder_check))
      |> render("show.json", workorder_check: workorder_check)
    end
  end

  def show(conn, %{"id" => id}) do
    workorder_check = Workorder.get_workorder_check!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", workorder_check: workorder_check)
  end

  def update(conn, %{"id" => id, "workorder_check" => workorder_check_params}) do
    workorder_check = Workorder.get_workorder_check!(id, conn.assigns.sub_domain_prefix)
    IO.inspect(workorder_check)
    with {:ok, %WorkorderCheck{} = workorder_check} <- Workorder.update_workorder_check(workorder_check, workorder_check_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", workorder_check: workorder_check)
    end
  end

  def update_work_permit_checks(conn, %{"workorder_checks" => %{"workorder_check_ids" => workorder_check_ids}}) do
    workorder_checks =  Workorder.update_workorder_checks(workorder_check_ids, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", workorder_checks: workorder_checks)
  end

  def self_update_pre(conn, %{"workorder_checks" => %{"workorder_check_ids" => workorder_check_ids}}) do
    workorder_checks = Workorder.update_pre_checks(workorder_check_ids, conn.assigns.sub_domain_prefix, conn.assigns.current_user)
    render(conn, "index.json", workorder_checks: workorder_checks)
  end

  def delete(conn, %{"id" => id}) do
    workorder_check = Workorder.get_workorder_check!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderCheck{}} <- Workorder.delete_workorder_check(workorder_check, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
