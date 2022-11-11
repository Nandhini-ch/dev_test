defmodule Inconn2ServiceWeb.SavedDashboardFilterView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.SavedDashboardFilterView

  def render("index.json", %{saved_dashboard_filters: saved_dashboard_filters}) do
    %{data: render_many(saved_dashboard_filters, SavedDashboardFilterView, "saved_dashboard_filter.json")}
  end

  def render("show.json", %{saved_dashboard_filter: saved_dashboard_filter}) do
    %{data: render_one(saved_dashboard_filter, SavedDashboardFilterView, "saved_dashboard_filter.json")}
  end

  def render("saved_dashboard_filter.json", %{saved_dashboard_filter: saved_dashboard_filter}) do
    %{id: saved_dashboard_filter.id,
      widget_code: saved_dashboard_filter.widget_code,
      site_id: saved_dashboard_filter.site_id,
      user_id: saved_dashboard_filter.user_id,
      config: saved_dashboard_filter.config}
  end
end
