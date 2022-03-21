defmodule Inconn2ServiceWeb.AssetController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetConfig

  def get_asset_from_qr_code(conn, %{"qr_code" => qr_code}) do
    {asset_type, asset} = AssetConfig.get_asset_from_qr_code(qr_code, conn.assigns.sub_domain_prefix)
    case asset_type do
      "L" ->
        render(conn, "location_render.json", location: asset)

      "E" ->
        render(conn, "equipment_render.json", equipment: asset)
    end
  end

end
