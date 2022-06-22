defmodule Inconn2Service.InventoryManagement.InventorySupplierItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.InventoryManagement.{InventoryItem, InventorySupplier}

  schema "inventory_supplier_items" do
    # field :inventory_supplier_id, :id
    belongs_to :inventory_supplier, InventorySupplier
    # field :inventory_item_id, :id
    belongs_to :inventory_item, InventoryItem

    timestamps()
  end

  @doc false
  def changeset(inventory_supplier_item, attrs) do
    inventory_supplier_item
    |> cast(attrs, [:inventory_supplier_id, :inventory_item_id])
    |> validate_required([:inventory_supplier_id, :inventory_item_id])
  end
end
