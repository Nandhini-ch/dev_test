defmodule Inconn2Service.Repo.Migrations.AddFieldsToEquipmentAttachments do
  use Ecto.Migration

  def change do
   alter table("equipment_attachments") do
     add :file_size, :string
   end
  end
end
