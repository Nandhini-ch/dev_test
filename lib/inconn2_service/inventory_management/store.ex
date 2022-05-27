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
    belongs_to :site, Inconn2Service.AssetConfig.Site

    timestamps()
  end

  @doc false
  def changeset(store, attrs) do
    store
    |> cast(attrs, [:name, :description, :location_id, :aisle_count, :aisle_notation, :row_count, :row_notation, :bin_count, :bin_notation, :site_id])
    |> validate_required([:name, :location_id, :aisle_count, :aisle_notation, :row_count, :row_notation, :bin_count, :bin_notation])
  end
end
