defmodule Inconn2Service.IotService.Asset do
  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.IotService.ApiCalls

  def list_assets_of_meters_and_sensors(site_id, prefix) do
    "inc_" <> sub_domain = prefix
    asset_ids_map = ApiCalls.asset_ids_of_meters_and_sensors(site_id, sub_domain) |> IO.inspect()
    locations = AssetConfig.list_locations_by_ids(asset_ids_map["location_ids"], prefix) |> Enum.map(&(add_asset_type_to_asset(&1, "L")))
    equipments = AssetConfig.list_equipments_by_ids(asset_ids_map["equipment_ids"], prefix) |> Enum.map(&(add_asset_type_to_asset(&1, "E")))
    locations ++ equipments
  end

  def add_device_to_asset("L", asset_id, {device_key, device_id}, prefix) do
    location = AssetConfig.get_location!(asset_id, prefix)
    attrs =
      %{
        "is_iot_enabled" => true,
        "iot_details" => update_iot_details_map(location.iot_details, {device_key, device_id})
        }
    AssetConfig.update_location(location, attrs, prefix)
  end

  def add_device_to_asset("E", asset_id, {device_key, device_id}, prefix) do
    equipment = AssetConfig.get_equipment!(asset_id, prefix)
    attrs =
      %{
        "is_iot_enabled" => true,
        "iot_details" => update_iot_details_map(equipment.iot_details, {device_key, device_id})
        }
    AssetConfig.update_equipment(equipment, attrs, prefix)
  end

  defp update_iot_details_map(iot_details, {device_key, device_id}) do
    ids = Map.get(iot_details, device_key, [])
    Map.put(iot_details, device_key, Enum.uniq([device_id | ids]))
  end
end
