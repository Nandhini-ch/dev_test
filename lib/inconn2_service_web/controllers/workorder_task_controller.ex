defmodule Inconn2ServiceWeb.WorkorderTaskController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkorderTask

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    workorder_tasks = Workorder.list_workorder_tasks(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", workorder_tasks: workorder_tasks)
  end

  def index_by_workorder(conn, %{"work_order_id" => work_order_id}) do
    workorder_tasks = Workorder.list_workorder_tasks(conn.assigns.sub_domain_prefix, work_order_id)
    render(conn, "index.json", workorder_tasks: workorder_tasks)
  end

  def create(conn, %{"workorder_task" => workorder_task_params}) do
    with {:ok, %WorkorderTask{} = workorder_task} <- Workorder.create_workorder_task(workorder_task_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.workorder_task_path(conn, :show, workorder_task))
      |> render("show.json", workorder_task: workorder_task)
    end
  end

  def show(conn, %{"id" => id}) do
    workorder_task = Workorder.get_workorder_task!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", workorder_task: workorder_task)
  end

  def update(conn, %{"id" => id, "workorder_task" => workorder_task_params}) do
    workorder_task = Workorder.get_workorder_task!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderTask{} = workorder_task} <- Workorder.update_workorder_task(workorder_task, workorder_task_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", workorder_task: workorder_task)
    end
  end

  def delete(conn, %{"id" => id}) do
    workorder_task = Workorder.get_workorder_task!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderTask{}} <- Workorder.delete_workorder_task(workorder_task, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
