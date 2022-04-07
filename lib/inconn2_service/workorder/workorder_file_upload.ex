defmodule Inconn2Service.Workorder.WorkorderFileUpload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workorder_file_uploads" do
    field :file, :string
    field :file_type, :string
    field :workorder_task_id, :integer

    timestamps()
  end

  @doc false
  def changeset(workorder_file_upload, attrs) do
    workorder_file_upload
    |> cast(attrs, [:file, :file_type, :workorder_task_id])
    |> validate_required([:file, :file_type, :workorder_task_id])
  end
end
