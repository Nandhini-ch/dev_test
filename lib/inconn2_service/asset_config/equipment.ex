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
    field :tag_name, :string
    field :description, :string
    field :function, :string
    field :asset_owned_by_id, :integer
    field :is_movable, :boolean
    field :is_iot_enabled, :boolean, default: false
    field :iot_details, :map, default: %{}
    field :department, :string
    field :asset_manager_id, :integer
    field :maintenance_manager_id, :integer
    field :created_on, :naive_datetime
    field :asset_class, :string
    field :custom, :map
    belongs_to :asset_category, AssetCategory
    belongs_to :site, Site
    belongs_to :location, Location

    timestamps()
  end

  @doc false
  def changeset(equipment, attrs) do
    equipment
    |> cast(attrs, [:name, :equipment_code, :is_iot_enabled, :iot_details, :parent_id, :asset_category_id, :status, :criticality, :site_id, :location_id, :connections_in, :connections_out, :active,
                              :tag_name, :description, :function, :asset_owned_by_id, :is_movable, :department, :asset_manager_id, :maintenance_manager_id, :created_on,
                              :asset_class, :custom])
    |> validate_required([:name, :equipment_code, :asset_category_id, :site_id, :location_id])
    |> validate_inclusion(:status, ["ON", "OFF", "BRK", "PRS", "TRN", "WRO"])
    |> validate_inclusion(:criticality, [1, 2, 3, 4, 5])
    |> assoc_constraint(:site)
    |> assoc_constraint(:asset_category)
    |> assoc_constraint(:location)
    # |> unique_constraint(:equipment_code)
    # |> unique_constraint(:unique_equipments, [name: :unique_equipments, message: "Equipment code already exists"])
  end


end
