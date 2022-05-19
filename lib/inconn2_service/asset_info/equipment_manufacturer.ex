defmodule Inconn2Service.AssetInfo.EquipmentManufacturer do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Equipment

  schema "equipment_manufacturers" do
    field :acquired_date, :date
    field :capacity, :float
    field :commissioned_date, :date
    field :country_of_origin, :string
    field :depreciation_factor, :float
    field :description, :string
    field :is_warranty_available, :boolean, default: false
    field :model_no, :string
    field :name, :string
    field :purchase_price, :float
    field :serial_no, :string
    field :unit_of_capacity, :string
    field :warranty_from, :date
    field :warranty_to, :date
    field :year_of_manufacturing, :integer
    field :manufacturer_id, :integer
    field :service_branch_id, :integer
    belongs_to :equipment, Equipment

    timestamps()
  end

  @doc false
  def changeset(equipment_manufacturer, attrs) do
    equipment_manufacturer
    |> cast(attrs, [:name, :model_no, :serial_no, :capacity, :unit_of_capacity, :year_of_manufacturing, :acquired_date, :commissioned_date, :purchase_price, :depreciation_factor, :description, :is_warranty_available, :warranty_from, :warranty_to, :country_of_origin])
    |> validate_required([:name, :model_no, :serial_no, :capacity, :unit_of_capacity, :year_of_manufacturing, :acquired_date, :commissioned_date, :purchase_price, :depreciation_factor, :description, :is_warranty_available, :warranty_from, :warranty_to, :country_of_origin])
  end
end
