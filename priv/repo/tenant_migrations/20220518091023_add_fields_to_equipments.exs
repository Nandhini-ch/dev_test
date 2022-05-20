defmodule Inconn2Service.Repo.Migrations.AddFieldsToEquipments do
  use Ecto.Migration

  def change do
    alter table("equipments") do
      add :tag_name, :string
      add :description, :text
      add :function, :string
      add :asset_owned_by_id, :integer
      add :is_movable, :boolean
      add :department, :string
      add :asset_manager_id, :integer
      add :maintenance_manager_id, :integer
      add :created_on, :naive_datetime
      add :asset_class, :string
    end
  end
end
