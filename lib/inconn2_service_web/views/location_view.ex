defmodule Inconn2ServiceWeb.LocationView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.LocationView

  def render("index.json", %{locations: locations}) do
    %{data: render_many(locations, LocationView, "location.json")}
  end

  def render("tree.json", %{locations: locations}) do
    %{data: render_many(locations, LocationView, "location_node.json")}
  end

  def render("show.json", %{location: location}) do
    %{data: render_one(location, LocationView, "location.json")}
  end

  def render("asset_qrs.json", %{locations: locations}) do
    %{data: render_many(locations, LocationView, "asset_qr.json")}
  end

  def render("asset_qr.json", %{equipment: equipment}) do
    %{
      id: equipment.id,
      asset_name: equipment.asset_name,
      asset_code: equipment.asset_code,
      asset_qr_ul: equipment.asset_qr_url
    }
  end

  def render("location.json", %{location: location}) do
    %{
      id: location.id,
      name: location.name,
      description: location.description,
      location_code: location.location_code,
      site_id: location.site_id,
      status: location.status,
      criticality: location.criticality,
      asset_category_id: location.asset_category_id,
      qr_code: location.qr_code,
      parent_id: List.last(location.path)
    }
  end

  def render("location_node.json", %{location: location}) do
    %{
      id: location.id,
      name: location.name,
      description: location.description,
      location_code: location.location_code,
      site_id: location.site_id,
      status: location.status,
      criticality: location.criticality,
      asset_category_id: location.asset_category_id,
      qr_code: location.qr_code,
      parent_id: List.last(location.path),
      children: render_many(location.children, LocationView, "location_node.json")
    }
  end
end
