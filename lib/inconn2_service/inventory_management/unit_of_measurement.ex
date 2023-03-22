defmodule Inconn2Service.InventoryManagement.UnitOfMeasurement do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.InventoryManagement.{InventoryItem, UomCategory}

  schema "unit_of_measurements" do
    field :name, :string
    field :unit, :string
    field :active, :boolean, default: true
    belongs_to :uom_category, UomCategory
    has_many  :inventory_items, InventoryItem, foreign_key: :inventory_unit_of_measurement_id
    has_many :consume_items, InventoryItem, foreign_key: :consume_unit_of_measurement_id
    has_many :purchase_items, InventoryItem, foreign_key: :purchase_unit_of_measurement_id

    timestamps()
  end

  @doc false
  def changeset(unit_of_measurement, attrs) do
    unit_of_measurement
    |> cast(attrs, [:name, :unit, :uom_category_id, :active])
    |> validate_required([:name, :unit, :uom_category_id])
    |> foreign_key_constraint(:uom_category_id)
  end
end
