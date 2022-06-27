defmodule Inconn2Service.Repo.Migrations.AddFieldsToInventoryManagement do
  use Ecto.Migration

  def change do
    alter table("uom_categories") do
      add :active, :boolean, default: true
    end

    alter table("unit_of_measurements") do
      add :active, :boolean, default: true
    end

    alter table("inventory_suppliers") do
      add :supplier_code, :string
      add :active, :boolean, default: true
    end

    alter table("stores") do
      add :person_or_location_based, :string
      add :user_id, :integer
      add :is_layout_configuration_required, :boolean, default: false
      add :store_image, :binary
      add :active, :boolean, default: true
    end

    alter table("inventory_items") do
      add :active, :boolean, default: true
    end

  end
end
