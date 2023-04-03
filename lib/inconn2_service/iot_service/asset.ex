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
end
