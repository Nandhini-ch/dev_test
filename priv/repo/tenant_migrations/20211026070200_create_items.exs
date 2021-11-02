defmodule Inconn2Service.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :part_no, :string
      add :name, :string
      add :type, :string
      add :purchase_unit_uom_id, :integer
      add :inventory_unit_uom_id, :integer
      add :consume_unit_uom_id, :integer
      add :reorder_quantity, :float
      add :min_order_quantity, :float
      add :asset_categories_ids, {:array, :integer}

      timestamps()
    end

  end
end
