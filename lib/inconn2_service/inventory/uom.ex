defmodule Inconn2Service.Inventory.UOM do
  use Ecto.Schema
  import Ecto.Changeset

  schema "uoms" do
    field :name, :string
    field :symbol, :string
    field :uom_type, :string

    timestamps()
  end

  @doc false
  def changeset(uom, attrs) do
    uom
    |> cast(attrs, [:name, :symbol, :uom_type])
    |> validate_required([:name, :symbol, :uom_type])
    |> validate_inclusion(:uom_type, ["physical", "cost"])
  end
end
