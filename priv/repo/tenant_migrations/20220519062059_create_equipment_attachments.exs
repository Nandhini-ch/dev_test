defmodule Inconn2Service.Repo.Migrations.CreateEquipmentAttachments do
  use Ecto.Migration

  def change do
    create table(:equipment_attachments) do
      add :name, :string
      add :attachment, :binary
      add :attachment_type, :string
      add :equipment_id, references(:equipments, on_delete: :nothing)

      timestamps()
    end

    create index(:equipment_attachments, [:equipment_id])
  end
end
