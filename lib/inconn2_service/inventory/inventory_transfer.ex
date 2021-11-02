defmodule Inconn2Service.Inventory.InventoryTransfer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "inventory_transfers" do
    field :from_location_id, :integer
    field :quantity, :integer
    field :reference, :string
    field :to_location_id, :integer
    field :uom_id, :integer
    field :item_id, :integer

    timestamps()
  end

  @doc false
  def changeset(inventory_transfer, attrs) do
    inventory_transfer
    |> cast(attrs, [:from_location_id, :to_location_id, :uom_id, :quantity, :reference, :item_id])
    |> validate_required([:from_location_id, :to_location_id, :uom_id, :quantity, :item_id])
  end
end
