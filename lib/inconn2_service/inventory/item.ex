defmodule Inconn2Service.Inventory.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias Inconn2Service.Inventory.UOM

  schema "items" do
    field :asset_categories_ids, {:array, :integer}
    field :consume_unit_uom_id, :integer
    field :inventory_unit_uom_id, :integer
    field :min_order_quantity, :float
    field :name, :string
    field :part_no, :string
    field :purchase_unit_uom_id, :integer
    field :reorder_quantity, :float
    field :type, :string
    has_many :inventory_transactions, Inconn2Service.Inventory.InventoryTransaction


    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:part_no, :name, :type, :purchase_unit_uom_id, :inventory_unit_uom_id, :consume_unit_uom_id, :reorder_quantity, :min_order_quantity, :asset_categories_ids])
    |> validate_required([:part_no, :name, :type, :purchase_unit_uom_id, :inventory_unit_uom_id, :consume_unit_uom_id, :reorder_quantity, :min_order_quantity, :asset_categories_ids])
    |> validate_inclusion(:type, ["tools", "spares", "consumables"])
  end
end
