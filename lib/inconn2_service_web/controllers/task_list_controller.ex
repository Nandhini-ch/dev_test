defmodule Inconn2ServiceWeb.TaskListController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.WorkOrderConfig
  alias Inconn2Service.WorkOrderConfig.TaskList

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    task_lists = WorkOrderConfig.list_task_lists(conn.query_param, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", task_lists: task_lists)
  end

  def create(conn, %{"task_list" => task_list_params}) do
    with {:ok, %TaskList{} = task_list} <- WorkOrderConfig.create_task_list(task_list_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("task_list", Routes.task_list_path(conn, :show, task_list))
      |> render("show.json", task_list: task_list)
    end
  end

  def show(conn, %{"id" => id}) do
    task_list = WorkOrderConfig.get_task_list!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", task_list: task_list)
  end

  def update(conn, %{"id" => id, "task_list" => task_list_params}) do
    task_list = WorkOrderConfig.get_task_list!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %TaskList{} = task_list} <- WorkOrderConfig.update_task_list(task_list, task_list_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", task_list: task_list)
    end
  end

  def delete(conn, %{"id" => id}) do
    task_list = WorkOrderConfig.get_task_list!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %TaskList{}} <- WorkOrderConfig.delete_task_list(task_list, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

  def activate_task_list(conn, %{"id" => id}) do
    task_list = WorkOrderConfig.get_task_list!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %TaskList{} = task_list} <- WorkOrderConfig.update_task_list(task_list, %{"active" => true}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", task_list: task_list)
    end
  end

  def deactivate_task_list(conn, %{"id" => id}) do
    task_list = WorkOrderConfig.get_task_list!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %TaskList{} = task_list} <- WorkOrderConfig.update_task_list(task_list, %{"active" => false}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", task_list: task_list)
    end
  end
end
