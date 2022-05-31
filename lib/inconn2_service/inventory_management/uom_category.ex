defmodule Inconn2Service.InventoryManagement.UomCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "uom_categories" do
    field :description, :string
    field :name, :string
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(uom_category, attrs) do
    uom_category
    |> cast(attrs, [:name, :description, :active])
    |> validate_required([:name])
  end
end
