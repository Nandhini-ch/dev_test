defmodule Inconn2Service.Repo.Migrations.CreateWorkorderFileUploads do
  use Ecto.Migration

  def change do
    create table(:workorder_file_uploads) do
      add :file, :string
      add :file_type, :string
      add :workorder_task_id, :integer

      timestamps()
    end

  end
end
