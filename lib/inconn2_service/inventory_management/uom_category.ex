defmodule Inconn2Service.InventoryManagement.UomCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "uom_categories" do
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(uom_category, attrs) do
    uom_category
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
