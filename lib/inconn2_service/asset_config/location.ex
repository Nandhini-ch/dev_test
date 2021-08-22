defmodule Inconn2Service.AssetConfig.Location do
  use Ecto.Schema

  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Site
  alias Inconn2Service.AssetConfig.AssetCategory

  schema "locations" do
    field :location_code, :string
    field :description, :string
    field :name, :string
    belongs_to :asset_category, AssetCategory
    belongs_to :site, Site
    field :parent_id, :integer, virtual: true
    field :path, {:array, :integer}, default: []

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :description, :location_code, :asset_category_id, :site_id, :parent_id])
    |> validate_required([:name, :location_code, :asset_category_id, :site_id])
    |> assoc_constraint(:site)
    |> assoc_constraint(:asset_category)
  end
end
