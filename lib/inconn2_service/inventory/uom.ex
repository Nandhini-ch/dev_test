defmodule Inconn2Service.Inventory.UOM do
  use Ecto.Schema
  import Ecto.Changeset

  schema "uoms" do
    field :name, :string
    field :symbol, :string

    timestamps()
  end

  @doc false
  def changeset(uom, attrs) do
    uom
    |> cast(attrs, [:name, :symbol])
    |> validate_required([:name, :symbol])
  end
end
