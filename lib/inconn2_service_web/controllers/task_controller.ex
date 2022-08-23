defmodule Inconn2ServiceWeb.TaskController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.WorkOrderConfig
  alias Inconn2Service.WorkOrderConfig.Task

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    case Map.get(conn.query_params, "label", nil) do
      nil ->
        tasks = WorkOrderConfig.list_tasks(conn.query_params, conn.assigns.sub_domain_prefix)
        render(conn, "index.json", tasks: tasks)
      label ->
        tasks = WorkOrderConfig.search_tasks(label, conn.assigns.sub_domain_prefix)
        render(conn, "index.json", tasks: tasks)
    end
  end

  def create(conn, %{"task" => task_params}) do
    with {:ok, %Task{} = task} <- WorkOrderConfig.create_task(task_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("task", Routes.task_path(conn, :show, task))
      |> render("show.json", task: task)
    end
  end

  def show(conn, %{"id" => id}) do
    task = WorkOrderConfig.get_task!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", task: task)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = WorkOrderConfig.get_task!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Task{} = task} <- WorkOrderConfig.update_task(task, task_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", task: task)
    end
  end

  def delete(conn, %{"id" => id}) do
    task = WorkOrderConfig.get_task!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Task{}} <- WorkOrderConfig.delete_task(task, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

  def activate_task(conn, %{"id" => id}) do
    task = WorkOrderConfig.get_task!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Task{} = task} <- WorkOrderConfig.update_active_status_for_task(task, %{"active" => true}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", task: task)
    end
  end

  def deactivate_task(conn, %{"id" => id}) do
    task = WorkOrderConfig.get_task!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Task{} = task} <- WorkOrderConfig.update_active_status_for_task(task, %{"active" => false}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", task: task)
    end
  end
end
