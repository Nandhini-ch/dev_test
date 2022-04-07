defmodule Inconn2ServiceWeb.WorkorderFileUploadView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.WorkorderFileUploadView

  def render("index.json", %{workorder_file_uploads: workorder_file_uploads}) do
    %{data: render_many(workorder_file_uploads, WorkorderFileUploadView, "workorder_file_upload.json")}
  end

  def render("show.json", %{workorder_file_upload: workorder_file_upload}) do
    %{data: render_one(workorder_file_upload, WorkorderFileUploadView, "workorder_file_upload.json")}
  end

  def render("workorder_file_upload.json", %{workorder_file_upload: workorder_file_upload}) do
    %{id: workorder_file_upload.id,
      file: workorder_file_upload.file,
      file_type: workorder_file_upload.file_type,
      workorder_task_id: workorder_file_upload.workorder_task_id}
  end
end
