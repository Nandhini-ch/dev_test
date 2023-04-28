defmodule Inconn2Service.Common.PublicUom do
  use Ecto.Schema
  import Ecto.Changeset

  schema "public_uoms" do
    field :description, :string
    field :uom_category, :string
    field :uom_unit, :string

    timestamps()
  end

  @doc false
  def changeset(public_uom, attrs) do
    public_uom
    |> cast(attrs, [:uom_category, :uom_unit, :description])
    |> validate_required([:uom_category, :uom_unit, :description])
  end
end
