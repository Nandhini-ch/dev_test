defmodule Inconn2Service.Inventory.UOM do
  use Ecto.Schema
  import Ecto.Changeset

  schema "uoms" do
    field :name, :string
    field :symbol, :string
    field :uom_type, :string
    field :active, :boolean, default: true
    has_many :inventory_items, Inconn2Service.Inventory.Item, foreign_key: :inventory_unit_uom_id
    has_many :consume_items, Inconn2Service.Inventory.Item, foreign_key: :consume_unit_uom_id
    has_many :purchase_items, Inconn2Service.Inventory.Item, foreign_key: :purchase_unit_uom_id


    timestamps()
  end

  @doc false
  def changeset(uom, attrs) do
    uom
    |> cast(attrs, [:name, :symbol, :uom_type, :active])
    |> validate_required([:name, :symbol])
    |> validate_inclusion(:uom_type, ["physical", "cost"])
  end
end
