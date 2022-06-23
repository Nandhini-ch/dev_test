defmodule Inconn2Service.Repo.Migrations.CreateInventorySupplierItems do
  use Ecto.Migration

  def change do
    create table(:inventory_supplier_items) do
      add :inventory_supplier_id, references(:inventory_suppliers, on_delete: :nothing)
      add :inventory_item_id, references(:inventory_items, on_delete: :nothing)

      timestamps()
    end

    create index(:inventory_supplier_items, [:inventory_supplier_id])
    create index(:inventory_supplier_items, [:inventory_item_id])
  end
end
