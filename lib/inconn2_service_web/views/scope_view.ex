defmodule Inconn2ServiceWeb.ScopeView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{AssetCategoryView, LocationView, ScopeView, SiteView}

  def render("index.json", %{scopes: scopes}) do
    %{data: render_many(scopes, ScopeView, "scope.json")}
  end

  def render("show.json", %{scope: scope}) do
    %{data: render_one(scope, ScopeView, "scope.json")}
  end

  def render("scope.json", %{scope: scope}) do
    %{id: scope.id,
      is_applicable_to_all_location: scope.is_applicable_to_all_location,
      location_ids: scope.location_ids,
      locations: render_many(scope.locations, LocationView, "location_only_name.json"),
      is_applicable_to_all_asset_category: scope.is_applicable_to_all_asset_category,
      asset_category_ids: scope.asset_category_ids,
      asset_categories: render_many(scope.asset_categories, AssetCategoryView, "asset_category_only_name.json"),
      site_id: scope.site_id,
      site: render_one(scope.site, SiteView, "site.json"),
      name: scope.name,
      contract_id: scope.contract_id}
  end

  def render("sites.json", %{sites: sites}) do
    %{data: render_many(sites, SiteView, "site.json")}
  end
end
