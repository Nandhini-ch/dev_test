defmodule Inconn2Service.InventoryManagement.InventoryItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.InventoryManagement.UnitOfMeasurement

  schema "inventory_items" do
    field :approval_user_id, :integer
    field :asset_category_ids, {:array, :integer}
    field :attachment, :binary
    field :is_approval_required, :boolean, default: false
    field :item_type, :string
    field :minumum_stock_level, :integer
    field :name, :string
    field :part_no, :string
    field :remarks, :string
    field :unit_price, :float
    field :uom_category_id, :integer
    belongs_to :consume_unit_of_measurement, UnitOfMeasurement
    belongs_to :inventory_unit_of_measurement, UnitOfMeasurement
    belongs_to :purchase_unit_of_measurement, UnitOfMeasurement

    timestamps()
  end

  @doc false
  def changeset(inventory_item, attrs) do
    inventory_item
    |> cast(attrs, [:name, :part_no, :item_type, :minumum_stock_level, :remarks, :attachment, :uom_category_id, :unit_price, :is_approval_required, :approval_user_id, :asset_category_ids,
                              :cosume_unit_of_measurement_id, :inventory_unit_of_measurement_id, :purchase_unit_of_measurement_id])
    |> validate_required([:name, :part_no, :item_type, :minumum_stock_level, :remarks, :attachment, :uom_category_id, :unit_price, :is_approval_required, :approval_user_id, :asset_category_ids,
                                            :cosume_unit_of_measurement_id, :inventory_unit_of_measurement_id, :purchase_unit_of_measurement_id])
    |> validate_inclusion(:item_type, ["Spare", "Parts", "Tools", "Consumables"])
  end
end
