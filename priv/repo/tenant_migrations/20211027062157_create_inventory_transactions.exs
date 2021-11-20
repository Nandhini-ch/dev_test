defmodule Inconn2Service.Repo.Migrations.CreateInventoryTransactions do
  use Ecto.Migration

  def change do
    create table(:inventory_transactions) do
      add :transaction_type, :string
      add :price, :float
      add :supplier_id, :integer
      add :quantity, :float
      add :reference, :text
      add :inventory_location_id, :integer
      add :item_id, :integer
      add :uom_id, :integer
      add :workorder_id, :integer
      add :remarks, :text
      add :cost, :float
      add :cost_unit_uom_id, :integer

      timestamps()
    end

  end
end
