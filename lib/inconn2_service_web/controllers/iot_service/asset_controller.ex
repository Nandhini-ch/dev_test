defmodule Inconn2ServiceWeb.IotService.AssetController do
  use Inconn2ServiceWeb, :controller
  alias Inconn2Service.IotService.Asset

  def assets_of_meters_and_sensors(conn, %{"site_id" => site_id}) do
    assets = Asset.list_assets_of_meters_and_sensors(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", assets: assets)
  end
end
