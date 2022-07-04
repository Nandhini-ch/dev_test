defmodule Inconn2Service.InventoryManagement.Conversion do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.InventoryManagement.{UnitOfMeasurement, UomCategory}

  schema "conversions" do
    field :multiplication_factor, :float
    belongs_to :from_unit_of_measurement, UnitOfMeasurement, foreign_key: :from_unit_of_measurement_id
    belongs_to :to_unit_of_measurement, UnitOfMeasurement, foreign_key: :to_unit_of_measurement_id
    belongs_to :uom_category, UomCategory
    field :active, :boolean, default: true


    timestamps()
  end

  @doc false
  def changeset(conversion, attrs) do
    conversion
    |> cast(attrs, [:from_unit_of_measurement_id, :to_unit_of_measurement_id, :uom_category_id, :multiplication_factor, :active])
    |> validate_required([:from_unit_of_measurement_id, :to_unit_of_measurement_id, :uom_category_id, :multiplication_factor])
  end
end
