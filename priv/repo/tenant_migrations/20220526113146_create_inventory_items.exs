defmodule Inconn2Service.Repo.Migrations.CreateInventoryItems do
  use Ecto.Migration

  def change do
    create table(:inventory_items) do
      add :name, :string
      add :part_no, :string
      add :item_type, :string
      add :minumum_stock_level, :integer
      add :remarks, :string
      add :attachment, :binary
      add :uom_category_id, :integer
      add :unit_price, :float
      add :is_approval_required, :boolean, default: false, null: false
      add :approval_user_id, :integer
      add :asset_category_ids, {:array, :integer}
      add :consume_unit_of_measurement_id, references(:unit_of_measurements, on_delete: :nothing)
      add :inventory_unit_of_measurement_id, references(:unit_of_measurements, on_delete: :nothing)
      add :purchase_unit_of_measurement_id, references(:unit_of_measurements, on_delete: :nothing)

      timestamps()
    end

    create index(:inventory_items, [:consume_unit_of_measurement_id])
    create index(:inventory_items, [:inventory_unit_of_measurement_id])
    create index(:inventory_items, [:purchase_unit_of_measurement_id])
  end
end
