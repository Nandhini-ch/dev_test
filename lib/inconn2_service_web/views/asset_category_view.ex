defmodule Inconn2ServiceWeb.AssetCategoryView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.AssetCategoryView

  def render("index.json", %{asset_categories: asset_categories}) do
    %{data: render_many(asset_categories, AssetCategoryView, "asset_category.json")}
  end

  def render("tree.json", %{asset_categories: asset_categories}) do
    %{data: render_many(asset_categories, AssetCategoryView, "asset_category_node.json")}
  end

  def render("show.json", %{asset_category: asset_category}) do
    %{data: render_one(asset_category, AssetCategoryView, "asset_category.json")}
  end

  def render("asset_category.json", %{asset_category: asset_category}) do
    %{
      id: asset_category.id,
      name: asset_category.name,
      asset_type: asset_category.asset_type
    }
  end

  def render("asset_category_node.json", %{asset_category: asset_category}) do
    %{
      id: asset_category.id,
      name: asset_category.name,
      asset_type: asset_category.asset_type,
      children: render_many(asset_category.children, AssetCategoryView, "asset_category_node.json")
    }
  end
end
