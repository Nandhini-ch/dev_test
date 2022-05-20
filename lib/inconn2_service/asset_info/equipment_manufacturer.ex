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
    |> cast(attrs, [:name, :model_no, :serial_no, :capacity, :unit_of_capacity, :year_of_manufacturing, :acquired_date, :commissioned_date, :purchase_price, :depreciation_factor, :description, :is_warranty_available, :warranty_from, :warranty_to, :country_of_origin, :manufacturer_id, :service_branch_id, :equipment_id])
    |> validate_required([:manufacturer_id, :equipment_id])
    |> validate_dates()
    |> validate_commissioned_date()
  end

  defp validate_dates(cs) do
    from_date = get_field(cs, :warranty_from)
    to_date = get_field(cs, :warranty_to)
    if not is_nil(from_date) and not is_nil(to_date) do
      case Date.compare(from_date, to_date) do
        :lt -> cs
        _ -> add_error(cs, :warranty_from, "should be less than end date")
      end
    else
      cs
    end
  end

  defp validate_commissioned_date(cs) do
    accuired_date = get_field(cs, :accuired_date)
    commissioned_date = get_field(cs, :commissioned_date)
    if not is_nil(accuired_date) and not is_nil(commissioned_date) do
      case Date.compare(accuired_date, commissioned_date) do
        :gt -> add_error(cs, :commissioned_date, "should be greater than equal to accuired date")
        _ -> cs
      end
    else
      cs
    end
  end

end
