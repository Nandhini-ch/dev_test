defmodule Inconn2Service.Inventory.SupplierItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "supplier_items" do
    field :item_id, :integer
    field :price, :float
    field :price_unit_uom_id, :integer
    field :supplier_id, :integer
    field :supplier_part_no, :string

    timestamps()
  end

  @doc false
  def changeset(supplier_item, attrs) do
    supplier_item
    |> cast(attrs, [:supplier_id, :item_id, :supplier_part_no, :price, :price_unit_uom_id])
    |> validate_required([:supplier_id, :item_id, :supplier_part_no, :price, :price_unit_uom_id])
  end
end
