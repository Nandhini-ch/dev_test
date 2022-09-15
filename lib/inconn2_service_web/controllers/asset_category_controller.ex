defmodule Inconn2ServiceWeb.AssetCategoryController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.AssetCategory

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    case Map.get(conn.query_params, "type", nil) do
      nil ->
        asset_categories = AssetConfig.list_asset_categories(conn.query_params, conn.assigns.sub_domain_prefix)
        render(conn, "index.json", asset_categories: asset_categories)
      type ->
        asset_categories = AssetConfig.list_asset_categories_by_type(type, conn.query_params, conn.assigns.sub_domain_prefix)
        render(conn, "index.json", asset_categories: asset_categories)
    end
  end

  def index_for_location(conn, %{"location_id" => location_id}) do
    asset_categories = AssetConfig.list_asset_categories_for_location(location_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", asset_categories: asset_categories)
  end

  def tree(conn, _params) do
    asset_categories = AssetConfig.list_asset_categories_tree(conn.assigns.sub_domain_prefix)
    render(conn, "tree.json", asset_categories: asset_categories)
  end

  def leaves(conn, _params) do
    asset_categories = AssetConfig.list_asset_categories_leaves(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", asset_categories: asset_categories)
  end

  def assets(conn, %{"id" => id}) do
    assets = AssetConfig.get_assets(id, conn.assigns.sub_domain_prefix)
    render(conn, "assets.json", assets: assets)
  end

  def assets_for_site(conn, %{"site_id" => site_id, "asset_category_id" => asset_category_id}) do
    assets = AssetConfig.get_assets(site_id, asset_category_id, conn.assigns.sub_domain_prefix)
    render(conn, "assets.json", assets: assets)
  end

  def create(conn, %{"asset_category" => asset_category_params}) do
    with {:ok, %AssetCategory{} = asset_category} <-
           AssetConfig.create_asset_category(asset_category_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("asset_category", Routes.asset_category_path(conn, :show, asset_category))
      |> render("show.json", asset_category: asset_category)
    end
  end

  def show(conn, %{"id" => id}) do
    asset_category = AssetConfig.get_asset_category!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", asset_category: asset_category)
  end

  def update(conn, %{"id" => id, "asset_category" => asset_category_params}) do
    asset_category = AssetConfig.get_asset_category!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %AssetCategory{} = asset_category} <-
           AssetConfig.update_asset_category(asset_category, asset_category_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", asset_category: asset_category)
    end
  end

  def delete(conn, %{"id" => id}) do
    asset_category = AssetConfig.get_asset_category!(id, conn.assigns.sub_domain_prefix)
    with {:ok, _asset_category} <-
      AssetConfig.delete_asset_category(asset_category, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
