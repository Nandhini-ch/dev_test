defmodule Inconn2ServiceWeb.WorkorderFileUploadController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkorderFileUpload

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    workorder_file_uploads = Workorder.list_workorder_file_uploads(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", workorder_file_uploads: workorder_file_uploads)
  end

  def index(conn, params) do
    if Map.has_key?(params, "workorder_task_id") do
      get_by_workorder_task_id(conn, params["workorder_task_id"])
    else
      list_for_workorder_task_file_upload(conn)
    end
  end

  def get_by_workorder_task_id(conn, %{"id" => id}) do
    workorder_file_upload = Workorder.get_workorder_file_upload_by_workorder_task_id(id, conn.assigns.sub_domain_prefix)
    case workorder_file_upload do
      nil ->
        {:error, :not_found}
      _ ->
        conn
        |> put_resp_content_type("image/png")
        |> send_resp(200, workorder_file_upload.file)
    end
  end

  def list_for_workorder_task_file_upload(conn) do
    workorder_file_upload = WorkOrder.list_workorder_file_uploads()
    render(conn, "index.json", workorder_file_upload: workorder_file_upload)
  end

  def create(conn, workorder_file_upload_params) do
    with {:ok, %WorkorderFileUpload{} = workorder_file_upload} <- Workorder.create_workorder_file_upload(workorder_file_upload_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.workorder_file_upload_path(conn, :show, workorder_file_upload))
      |> render("show.json", workorder_file_upload: workorder_file_upload)
    end
  end

  def show(conn, %{"id" => id}) do
    workorder_file_upload = Workorder.get_workorder_file_upload!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", workorder_file_upload: workorder_file_upload)
  end

  def update(conn, %{"id" => id, "workorder_file_upload" => workorder_file_upload_params}) do
    workorder_file_upload = Workorder.get_workorder_file_upload!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderFileUpload{} = workorder_file_upload} <- Workorder.update_workorder_file_upload(workorder_file_upload, workorder_file_upload_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", workorder_file_upload: workorder_file_upload)
    end
  end

  def delete(conn, %{"id" => id}) do
    workorder_file_upload = Workorder.get_workorder_file_upload!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderFileUpload{}} <- Workorder.delete_workorder_file_upload(workorder_file_upload, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
