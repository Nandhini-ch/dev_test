defmodule Inconn2Service.Repo.Migrations.AddCustomFieldToEquipments do
  use Ecto.Migration

  def change do
    alter table("equipments")  do
      add :custom, :map
    end
  end
end
