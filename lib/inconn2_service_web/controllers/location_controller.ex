defmodule Inconn2ServiceWeb.LocationController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.Location

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, %{"site_id" => site_id}) do
    locations = AssetConfig.list_locations(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", locations: locations)
  end

  def tree(conn, %{"site_id" => site_id}) do
    locations = AssetConfig.list_locations_tree(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "tree.json", locations: locations)
  end

  def leaves(conn, %{"site_id" => site_id}) do
    locations = AssetConfig.list_locations_leaves(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", locations: locations)
  end

  def create(conn, %{"location" => location_params}) do
    with {:ok, %Location{} = location} <-
           AssetConfig.create_location(location_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.location_path(conn, :show, location))
      |> render("show.json", location: location)
    end
  end

  def show(conn, %{"id" => id}) do
    location = AssetConfig.get_location!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", location: location)
  end

  def update(conn, %{"id" => id, "location" => location_params}) do
    location = AssetConfig.get_location!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Location{} = location} <-
           AssetConfig.update_location(location, location_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", location: location)
    end
  end

  def delete(conn, %{"id" => id}) do
    location = AssetConfig.get_location!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Location{}} <-
           AssetConfig.delete_location(location, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
