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
      applicable_to_all_location: scope.applicable_to_all_location,
      location_ids: scope.location_ids,
      applicable_to_all_asset_category: scope.applicable_to_all_asset_category,
      asset_category_ids: scope.asset_category_ids,
      start_date: scope.start_date,
      end_date: scope.end_date}
  end
end
