defmodule Inconn2ServiceWeb.IotService.AssetController do
  use Inconn2ServiceWeb, :controller
  alias Inconn2Service.IotService.Asset

  def assets_of_meters_and_sensors(conn, %{"site_id" => site_id}) do
    assets = Asset.list_assets_of_meters_and_sensors(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", assets: assets)
  end

  def add_device_to_asset(conn, %{"asset_id" => asset_id, "asset_type" => asset_type, "device_key" => device_key, "device_id" => device_id, "licensee_prefix" => prefix}) do
    IO.inspect(conn.query_params, label: "Asset update from IOT params")
    Asset.add_device_to_asset(asset_type, asset_id, {device_key, device_id}, "inc_" <> prefix) |> IO.inspect()
    render(conn, "success.json", data: "success")
  end
end
