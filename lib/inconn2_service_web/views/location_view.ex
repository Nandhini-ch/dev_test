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
      parent_id: List.last(location.path),
      children: render_many(location.children, LocationView, "location_node.json")
    }
  end
end
