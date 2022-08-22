defmodule Inconn2ServiceWeb.MasterTaskTypeController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.WorkOrderConfig
  alias Inconn2Service.WorkOrderConfig.MasterTaskType

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    master_task_types = WorkOrderConfig.list_master_task_types(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", master_task_types: master_task_types)
  end

  def create(conn, %{"master_task_type" => master_task_type_params}) do
    with {:ok, %MasterTaskType{} = master_task_type} <- WorkOrderConfig.create_master_task_type(master_task_type_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.master_task_type_path(conn, :show, master_task_type))
      |> render("show.json", master_task_type: master_task_type)
    end
  end

  def show(conn, %{"id" => id}) do
    master_task_type = WorkOrderConfig.get_master_task_type!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", master_task_type: master_task_type)
  end

  def update(conn, %{"id" => id, "master_task_type" => master_task_type_params}) do
    master_task_type = WorkOrderConfig.get_master_task_type!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %MasterTaskType{} = master_task_type} <- WorkOrderConfig.update_master_task_type(master_task_type, master_task_type_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", master_task_type: master_task_type)
    end
  end

  def delete(conn, %{"id" => id}) do
    master_task_type = WorkOrderConfig.get_master_task_type!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %MasterTaskType{}} <- WorkOrderConfig.delete_master_task_type(master_task_type, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
