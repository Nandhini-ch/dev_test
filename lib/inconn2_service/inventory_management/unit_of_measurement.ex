defmodule Inconn2Service.InventoryManagement.UnitOfMeasurement do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.InventoryManagement.UomCategory

  schema "unit_of_measurements" do
    field :name, :string
    field :unit, :string
    belongs_to :uom_category, UomCategory
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(unit_of_measurement, attrs) do
    unit_of_measurement
    |> cast(attrs, [:name, :unit, :uom_category_id, :active])
    |> validate_required([:name, :unit])
    |> foreign_key_constraint(:uom_category_id)
  end
end
