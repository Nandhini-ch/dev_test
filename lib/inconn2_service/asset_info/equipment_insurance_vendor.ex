defmodule Inconn2Service.AssetInfo.EquipmentInsuranceVendor do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Equipment

  schema "equipment_insurance_vendors" do
    field :end_date, :date
    field :insurance_policy_no, :string
    field :insurance_scope, :string
    field :service_branch_id, :integer
    field :start_date, :date
    field :vendor_id, :integer
    belongs_to :equipment, Equipment

    timestamps()
  end

  @doc false
  def changeset(equipment_insurance_vendor, attrs) do
    equipment_insurance_vendor
    |> cast(attrs, [:insurance_policy_no, :insurance_scope, :start_date, :end_date, :vendor_id, :service_branch_id, :equipment_id])
    |> validate_required([:insurance_policy_no, :insurance_scope, :start_date, :end_date, :vendor_id, :service_branch_id])
    |> validate_dates()
  end

  defp validate_dates(cs) do
    from_date = get_field(cs, :start_date)
    to_date = get_field(cs, :to_date)
    if not is_nil(from_date) or not is_nil(to_date) do
      case Date.compare(from_date, to_date) do
        :lt -> cs
        _ -> add_error(cs, :start_date, "should be less than end date")
      end
    else
      cs
    end
  end
end
