defmodule Inconn2ServiceWeb.IotService.AssetController do
  use Inconn2ServiceWeb, :controller
  alias Inconn2Service.IotService.Asset

  def meter_assets(conn, _params) do
    assets = Asset.list_assets()
    render(conn, "index.json", assets: assets)
  end

  def sensor_assets(conn, _params) do
    assets = Asset.list_assets()
    render(conn, "index.json", assets: assets)
  end
end
