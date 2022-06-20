defmodule Inconn2Service.Repo.Migrations.CreateStocks do
  use Ecto.Migration

  def change do
    create table(:stocks) do
      add :aisle, :string
      add :row, :string
      add :bin, :string
      add :quantity, :float
      add :inventory_item_id, references(:inventory_items, on_delete: :nothing)
      add :store_id, references(:stores, on_delete: :nothing)

      timestamps()
    end

    create index(:stocks, [:inventory_item_id])
    create index(:stocks, [:store_id])
  end
end
