defmodule Inconn2ServiceWeb.DashboardsView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{AssetCategoryView, LocationView}

  def render("high_level.json", %{data: data}) do
    %{
      data: data
    }
  end

  def render("detailed_charts.json", %{data: data}) do
    %{
      data: data
    }
  end

  def render("assets_asset_categories.json", %{asset_categories: asset_categories, locations: locations, equipments: equipments}) do
    %{
      data: %{
        asset_categories: render_many(asset_categories, AssetCategoryView, "asset_category.json"),
        assets: render_many(locations, LocationView, "location_asset_node.json") ++
                render_many(equipments, LocationView, "equipment_asset_node.json")
      }
    }
  end

end
