defmodule Inconn2Service.Repo.Migrations.CreateSupplierItems do
  use Ecto.Migration

  def change do
    create table(:supplier_items) do
      add :supplier_id, :integer
      add :item_id, :integer
      add :supplier_part_no, :string
      add :price, :float
      add :price_unit_uom_id, :integer

      timestamps()
    end

  end
end
