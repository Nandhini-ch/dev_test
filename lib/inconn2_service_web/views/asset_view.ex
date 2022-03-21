defmodule Inconn2ServiceWeb.AssetView do
  use Inconn2ServiceWeb, :view
  # alias Inconn2ServiceWeb.AssetView
  alias Inconn2ServiceWeb.{EquipmentView, LocationView}

  def render("location_render.json", %{location: asset}) do
    %{data: render_one(asset, LocationView, "location.json")}
  end

  def render("equipment_render.json", %{equipment: asset}) do
    %{data: render_one(asset, EquipmentView, "equipment.json")}
  end

end
