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
    field :is_iot_enabled, :boolean, default: false
    field :iot_details, :map, default: %{}
    field :criticality, :integer, default: 5
    field :parent_id, :integer, virtual: true
    field :path, {:array, :integer}, default: []
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :description, :is_iot_enabled, :iot_details, :location_code, :asset_category_id, :site_id, :status, :criticality, :parent_id, :active])
    |> validate_required([:name, :location_code, :iot_details, :asset_category_id, :site_id, :is_iot_enabled])
    |> validate_inclusion(:status, ["ON", "OFF", "BRK", "PRS", "TRN", "WRO"])
    |> validate_inclusion(:criticality, [1, 2, 3, 4, 5])
    |> assoc_constraint(:site)
    |> assoc_constraint(:asset_category)
    |> unique_constraint(:location_code)
  end
end
