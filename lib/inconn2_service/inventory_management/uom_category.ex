defmodule Inconn2Service.InventoryManagement.UomCategory do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.InventoryManagement.Conversion

  schema "uom_categories" do
    field :description, :string
    field :name, :string
    field :active, :boolean, default: true
    has_many :conversions, Conversion

    timestamps()
  end

  @doc false
  def changeset(uom_category, attrs) do
    uom_category
    |> cast(attrs, [:name, :description, :active])
    |> validate_required([:name])
  end
end
