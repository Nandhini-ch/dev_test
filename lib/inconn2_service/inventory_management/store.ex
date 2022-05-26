defmodule Inconn2Service.InventoryManagement.Store do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stores" do
    field :aisle_count, :integer
    field :aisle_notation, :string
    field :bin_count, :integer
    field :bin_notation, :string
    field :description, :string
    field :location_id, :integer
    field :name, :string
    field :row_count, :integer
    field :row_notation, :string
    field :site_id, :id

    timestamps()
  end

  @doc false
  def changeset(store, attrs) do
    store
    |> cast(attrs, [:name, :description, :location_id, :aisle_count, :aisle_notation, :row_count, :row_notation, :bin_count, :bin_notation])
    |> validate_required([:name, :description, :location_id, :aisle_count, :aisle_notation, :row_count, :row_notation, :bin_count, :bin_notation])
  end
end
