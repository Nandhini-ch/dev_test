defmodule Inconn2Service.Repo.Migrations.CreateInventoryTransfers do
  use Ecto.Migration

  def change do
    create table(:inventory_transfers) do
      add :from_location_id, :integer
      add :to_location_id, :integer
      add :uom_id, :integer
      add :quantity, :integer
      add :reference, :text
      add :item_id, :integer

      timestamps()
    end

  end
end
