defmodule Inconn2Service.AssetInfo.EquipmentDlpVendor do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Equipment

  schema "equipment_dlp_vendors" do
    field :dlp_from, :date
    field :dlp_to, :date
    field :is_asset_under_dlp, :boolean, default: false
    field :service_branch_id, :integer
    field :vendor_id, :integer
    field :vendor_scope, :string
    belongs_to :equipment, Equipment

    timestamps()
  end

  @doc false
  def changeset(equipment_dlp_vendor, attrs) do
    equipment_dlp_vendor
    |> cast(attrs, [:vendor_scope, :is_asset_under_dlp, :dlp_from, :dlp_to, :vendor_id, :service_branch_id, :equipment_id])
    |> validate_required([:vendor_id, :service_branch_id, :equipment_id])
    |> validate_dates()
  end

  defp validate_dates(cs) do
    from_date = get_field(cs, :dlp_from)
    to_date = get_field(cs, :dlp_to)
    if not is_nil(from_date) and not is_nil(to_date) do
      case Date.compare(from_date, to_date) do
        :lt -> cs
        _ -> add_error(cs, :dlp_from, "should be less than end date")
      end
    else
      cs
    end
  end
end
