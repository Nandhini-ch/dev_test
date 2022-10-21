defmodule Inconn2Service.InventoryManagement.InventorySupplierItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.InventoryManagement.{InventoryItem, InventorySupplier}

  schema "inventory_supplier_items" do
    belongs_to :inventory_supplier, InventorySupplier
    belongs_to :inventory_item, InventoryItem
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(inventory_supplier_item, attrs) do
    inventory_supplier_item
    |> cast(attrs, [:inventory_supplier_id, :inventory_item_id, :active])
    |> validate_required([:inventory_supplier_id, :inventory_item_id])
  end
end
