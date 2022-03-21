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

  def render("success.json", %{success: success}) do
    %{
      data: success
    }
  end

  def render("asset_details.json", %{asset: asset}) do
    %{
      id: asset.id,
      name: asset.name,
      asset_type: asset.asset_type
     }
  end

end
