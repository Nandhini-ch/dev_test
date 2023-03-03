defmodule Inconn2Service.AssetInfo.EquipmentInsuranceVendor do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Equipment

  schema "equipment_insurance_vendors" do
    field :end_date, :date
    field :insurance_policy_no, :string
    field :insurance_scope, :string
    field :service_branch, :string
    field :start_date, :date
    field :vendor, :string
    belongs_to :equipment, Equipment

    timestamps()
  end

  @doc false
  def changeset(equipment_insurance_vendor, attrs) do
    equipment_insurance_vendor
    |> cast(attrs, [:insurance_policy_no, :insurance_scope, :start_date, :end_date, :vendor, :service_branch, :equipment_id])
    |> validate_required([:insurance_policy_no, :insurance_scope, :start_date, :end_date, :vendor, :service_branch, :equipment_id])
    |> validate_dates()
  end

  defp validate_dates(cs) do
    from_date = get_field(cs, :start_date)
    to_date = get_field(cs, :to_date)
    if not is_nil(from_date) and not is_nil(to_date) do
      case Date.compare(from_date, to_date) do
        :lt -> cs
        _ -> add_error(cs, :start_date, "should be less than end date")
      end
    else
      cs
    end
  end
end
