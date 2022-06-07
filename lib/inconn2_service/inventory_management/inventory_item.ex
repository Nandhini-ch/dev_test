defmodule Inconn2Service.InventoryManagement.InventoryItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.InventoryManagement.{UomCategory, UnitOfMeasurement}

  schema "inventory_items" do
    field :approval_user_id, :integer
    field :asset_category_ids, {:array, :integer}
    field :attachment, :binary
    field :is_approval_required, :boolean, default: false
    field :item_type, :string
    field :minimum_stock_level, :integer
    field :name, :string
    field :part_no, :string
    field :remarks, :string
    field :unit_price, :float
    belongs_to  :uom_category, UomCategory
    belongs_to :consume_unit_of_measurement, UnitOfMeasurement, foreign_key: :consume_unit_of_measurement_id
    belongs_to :inventory_unit_of_measurement, UnitOfMeasurement, foreign_key: :inventory_unit_of_measurement_id
    belongs_to :purchase_unit_of_measurement, UnitOfMeasurement, foreign_key: :purchase_unit_of_measurement_id
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(inventory_item, attrs) do
    inventory_item
    |> cast(attrs, [:name, :part_no, :item_type, :minimum_stock_level, :remarks, :attachment, :uom_category_id, :unit_price, :is_approval_required, :approval_user_id, :asset_category_ids,
                              :consume_unit_of_measurement_id, :inventory_unit_of_measurement_id, :purchase_unit_of_measurement_id, :active])
    |> validate_required([:name, :part_no, :item_type, :minimum_stock_level, :remarks,  :uom_category_id, :unit_price, :is_approval_required, :asset_category_ids,
                                            :consume_unit_of_measurement_id, :inventory_unit_of_measurement_id, :purchase_unit_of_measurement_id])
    |> validate_inclusion(:item_type, ["Spare", "Part", "Tool", "Consumable"])
    |> foreign_key_constraint(:consume_unit_of_measurement_id)
    |> foreign_key_constraint(:inventory_unit_of_measurement_id)
    |> foreign_key_constraint(:purchase_unit_of_measurement_id)
  end

  def validate_approval_user_id(cs) do
    is_approval_required = get_change(cs, :is_approval_required, nil)
    cond do
      !is_nil(is_approval_required) and is_approval_required  -> validate_required(cs, [:approval_user_id])
      true -> cs
    end
  end
end
