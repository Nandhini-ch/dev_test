defmodule Inconn2Service.Repo.Migrations.CreateInventoryStocks do
  use Ecto.Migration

  def change do
    create table(:inventory_stocks) do
      add :inventory_location_id, :integer
      add :item_id, :integer
      add :quantity, :float

      timestamps()
    end

  end
end
