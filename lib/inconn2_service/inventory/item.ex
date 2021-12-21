defmodule Inconn2Service.Inventory.Item do
  use Ecto.Schema
  import Ecto.Changeset

  # alias Inconn2Service.Inventory.UOM

  schema "items" do
    field :asset_categories_ids, {:array, :integer}
    # field :consume_unit_uom_id, :integer
    belongs_to :consume_unit_uom, Inconn2Service.Inventory.UOM, foreign_key: :consume_unit_uom_id
    # field :inventory_unit_uom_id, :integer
    belongs_to :inventory_unit_uom, Inconn2Service.Inventory.UOM, foreign_key: :inventory_unit_uom_id
    field :min_order_quantity, :float
    field :name, :string
    field :part_no, :string
    # field :purchase_unit_uom_id, :integer
    belongs_to :purchase_unit_uom, Inconn2Service.Inventory.UOM, foreign_key: :purchase_unit_uom_id
    field :reorder_quantity, :float
    field :type, :string
    field :aisle, :string
    field :row, :string
    field :bin, :string
    field :critical, :boolean, default: false
    has_one :inventory_stock, Inconn2Service.Inventory.InventoryStock
    has_many :inventory_transactions, Inconn2Service.Inventory.InventoryTransaction
    has_many :supplier_items, Inconn2Service.Inventory.SupplierItem


    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:part_no, :name, :type, :purchase_unit_uom_id, :inventory_unit_uom_id, :consume_unit_uom_id, :reorder_quantity, :min_order_quantity, :asset_categories_ids, :aisle, :row, :bin, :critical])
    |> validate_required([:part_no, :name, :type, :purchase_unit_uom_id, :inventory_unit_uom_id, :consume_unit_uom_id, :reorder_quantity, :min_order_quantity, :asset_categories_ids])
    |> validate_inclusion(:type, ["tools", "spares", "consumables"])
  end
end
