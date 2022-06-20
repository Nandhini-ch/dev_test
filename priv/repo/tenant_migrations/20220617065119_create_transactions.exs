defmodule Inconn2Service.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :transaction_reference, :string
      add :transaction_type, :string
      add :transaction_user_id, :integer
      add :approver_user_id, :integer
      add :work_order_id, :integer
      add :is_acknowledged, :string
      add :is_approval_required, :boolean
      add :is_approved, :string
      add :quantity, :float
      add :unit_price, :float
      add :aisle, :string
      add :row, :string
      add :bin, :string
      add :cost, :float
      add :remarks, :string
      add :inventory_supplier_id, references(:inventory_suppliers, on_delete: :nothing)
      add :inventory_item_id, references(:inventory_items, on_delete: :nothing)
      add :unit_of_measurement_id, references(:unit_of_measurements, on_delete: :nothing)
      add :store_id, references(:stores, on_delete: :nothing)

      timestamps()
    end

    create index(:transactions, [:inventory_item_id])
    create index(:transactions, [:unit_of_measurement_id])
    create index(:transactions, [:store_id])
  end
end
