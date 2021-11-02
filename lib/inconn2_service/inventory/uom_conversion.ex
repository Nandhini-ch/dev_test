defmodule Inconn2Service.Inventory.UomConversion do
  use Ecto.Schema
  import Ecto.Changeset

  # alias Inconn2Service.Inventory

  schema "uom_conversions" do
    field :from_uom_id, :integer
    field :inverse_factor, :float
    field :mult_factor, :float
    field :to_uom_id, :integer


    timestamps()
  end

  @doc false
  def changeset(uom_conversion, attrs) do
    uom_conversion
    |> cast(attrs, [:from_uom_id, :to_uom_id, :mult_factor, :inverse_factor])
    |> validate_required([:from_uom_id, :to_uom_id, :mult_factor])
  end
end
