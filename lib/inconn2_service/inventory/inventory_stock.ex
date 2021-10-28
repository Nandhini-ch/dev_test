defmodule Inconn2Service.Inventory.InventoryStock do
  use Ecto.Schema
  import Ecto.Changeset

  schema "inventory_stocks" do
    belongs_to :inventory_location, Inconn2Service.Inventory.InventoryLocation
    belongs_to :item, Inconn2Service.Inventory.Item
    field :quantity, :float

    timestamps()
  end

  @doc false
  def changeset(inventory_stock, attrs) do
    inventory_stock
    |> cast(attrs, [:inventory_location_id, :item_id, :quantity])
    |> validate_required([:inventory_location_id, :item_id, :quantity])
  end
end
