defmodule Inconn2ServiceWeb.AssetCategoryController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.AssetCategory

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, %{"site_id" => site_id}) do
    asset_categories = AssetConfig.list_asset_categories(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", asset_categories: asset_categories)
  end

  def tree(conn, %{"site_id" => site_id}) do
    asset_categories = AssetConfig.list_asset_categories_tree(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "tree.json", asset_categories: asset_categories)
  end

  def leaves(conn, %{"site_id" => site_id}) do
    asset_categories = AssetConfig.list_asset_categories_leaves(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", asset_categories: asset_categories)
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
    with {:ok, %AssetCategory{}} <-
           AssetConfig.delete_asset_category(asset_category, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

end
