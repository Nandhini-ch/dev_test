defmodule Inconn2ServiceWeb.InventoryLocationView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.InventoryLocationView

  def render("index.json", %{inventory_locations: inventory_locations}) do
    %{data: render_many(inventory_locations, InventoryLocationView, "inventory_location.json")}
  end

  def render("show.json", %{inventory_location: inventory_location}) do
    %{data: render_one(inventory_location, InventoryLocationView, "inventory_location.json")}
  end

  def render("inventory_location.json", %{inventory_location: inventory_location}) do
    %{id: inventory_location.id,
      name: inventory_location.name,
      description: inventory_location.description,
      site_id: inventory_location.site_id,
      site_location_id: inventory_location.site_location_id}
  end
end
