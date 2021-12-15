defmodule Inconn2Service.AssetConfig.Equipment do
  use Ecto.Schema

  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Site
  alias Inconn2Service.AssetConfig.AssetCategory
  alias Inconn2Service.AssetConfig.Location

  schema "equipments" do
    field :name, :string
    field :equipment_code, :string
    field :parent_id, :integer, virtual: true
    field :path, {:array, :integer}, default: []
    field :connections_in, {:array, :integer}
    field :connections_out, {:array, :integer}
    field :active, :boolean, default: true
    field :qr_code, Ecto.UUID, autogenerate: true
    field :status, :string, default: "ON"
    field :criticality, :integer, default: 5
    belongs_to :asset_category, AssetCategory
    belongs_to :site, Site
    belongs_to :location, Location

    timestamps()
  end

  @doc false
  def changeset(equipment, attrs) do
    equipment
    |> cast(attrs, [:name, :equipment_code, :parent_id, :asset_category_id, :status, :criticality, :site_id, :location_id, :connections_in, :connections_out, :active])
    |> validate_required([:name, :equipment_code, :asset_category_id, :site_id, :location_id])
    |> validate_inclusion(:status, ["ON", "OFF", "BRK", "PRS", "TRN", "WRO"])
    |> validate_inclusion(:criticality, [1, 2, 3, 4, 5])
    |> assoc_constraint(:site)
    |> assoc_constraint(:asset_category)
    |> assoc_constraint(:location)

  end


end
