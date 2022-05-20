defmodule Inconn2Service.AssetInfo.EquipmentMaintenanceVendor do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Equipment

  schema "equipment_maintenance_vendors" do
    field :amc_frequency, :integer
    field :amc_from, :date
    field :amc_to, :date
    field :is_asset_under_amc, :boolean, default: false
    field :response_time_in_minutes, :integer
    field :service_branch_id, :integer
    field :vendor_id, :integer
    field :vendor_scope, :string
    belongs_to :equipment, Equipment

    timestamps()
  end

  @doc false
  def changeset(equipment_maintenance_vendor, attrs) do
    equipment_maintenance_vendor
    |> cast(attrs, [:vendor_scope, :is_asset_under_amc, :amc_from, :amc_to, :amc_frequency, :response_time_in_minutes, :vendor_id, :service_branch_id, :equipment_id])
    |> validate_required([:is_asset_under_amc, :vendor_id, :service_branch_id, :equipment_id])
    |> validate_dates()
  end

  defp validate_dates(cs) do
    from_date = get_field(cs, :amc_from)
    to_date = get_field(cs, :amc_to)
    if not is_nil(from_date) and not is_nil(to_date) do
      case Date.compare(from_date, to_date) do
        :lt -> cs
        _ -> add_error(cs, :amc_from, "should be less than end date")
      end
    else
      cs
    end
  end
end
