defmodule Inconn2ServiceWeb.ScopeView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.ScopeView

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
      is_applicable_to_all_asset_category: scope.is_applicable_to_all_asset_category,
      asset_category_ids: scope.asset_category_ids,
      site_id: scope.site_id,
      name: scope.name,
      contract_id: scope.contract_id}
  end
end
