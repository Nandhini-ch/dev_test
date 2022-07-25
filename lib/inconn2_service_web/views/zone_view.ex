defmodule Inconn2ServiceWeb.ZoneView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.ZoneView

  def render("index.json", %{zones: zones}) do
    %{data: render_many(zones, ZoneView, "zone.json")}
  end

  def render("tree.json", %{zones: zones}) do
    %{data: render_many(zones, ZoneView, "zone_node.json")}
  end

  def render("show.json", %{zone: zone}) do
    %{data: render_one(zone, ZoneView, "zone.json")}
  end

  def render("zone.json", %{zone: zone}) do
    %{id: zone.id,
      name: zone.name,
      description: zone.description,
      path: zone.path,
      parent_id: List.last(zone.path)
     }
  end

  def render("zone_node.json", %{zone: zone}) do
    %{id: zone.id,
      name: zone.name,
      description: zone.description,
      path: zone.path,
      parent_id: List.last(zone.path),
      children: render_many(zone.children, ZoneView, "zone_node.json")
      }
  end
end
