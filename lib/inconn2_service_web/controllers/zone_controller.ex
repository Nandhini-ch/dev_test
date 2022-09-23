defmodule Inconn2ServiceWeb.ZoneController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.Zone

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    zones = AssetConfig.list_zones(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", zones: zones)
  end

  def create(conn, %{"zone" => zone_params}) do
    with {:ok, %Zone{} = zone} <- AssetConfig.create_zone(zone_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.zone_path(conn, :show, zone))
      |> render("show.json", zone: zone)
    end
  end


  def show(conn, %{"id" => id}) do
    zone = AssetConfig.get_zone!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", zone: zone)
  end

  def tree(conn, _params) do
    zones = AssetConfig.list_zone_tree(conn.assigns.sub_domain_prefix)
    render(conn, "tree.json", zones: zones)
  end

  def update(conn, %{"id" => id, "zone" => zone_params}) do
    zone = AssetConfig.get_zone!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Zone{} = zone} <- AssetConfig.update_zone(zone, zone_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", zone: zone)
    end
  end

  def delete(conn, %{"id" => id}) do
    zone = AssetConfig.get_zone!(id, conn.assigns.sub_domain_prefix)

    with {:deleted, _} <-
       AssetConfig.delete_zone(zone, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
