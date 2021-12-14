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
    field :qr_code, Ecto.UUID, autogenerate: true
    field :status, :string, default: "ON"
    field :parent_id, :integer, virtual: true
    field :path, {:array, :integer}, default: []
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :description, :location_code, :asset_category_id, :site_id, :status, :parent_id, :active])
    |> validate_required([:name, :location_code, :asset_category_id, :site_id])
    |> validate_inclusion(:status, ["ON", "OFF", "BRK", "PRS", "TRN", "WRO"])
    |> assoc_constraint(:site)
    |> assoc_constraint(:asset_category)
  end
end
