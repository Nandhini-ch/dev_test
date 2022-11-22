defmodule Inconn2ServiceWeb.SavedDashboardFilterController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.DashboardConfiguration
  alias Inconn2Service.DashboardConfiguration.SavedDashboardFilter

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    saved_dashboard_filters = DashboardConfiguration.list_saved_dashboard_filters(conn.assigns.current_user, conn.query_params, conn.assigns.sub_domain_prefix)
    cond do
      !is_nil(conn.query_params["site_id"]) && !is_nil(conn.query_params["widget_code"]) ->
        render(conn, "show.json", saved_dashboard_filter: saved_dashboard_filters |> List.first())

      true ->
        render(conn, "index.json", saved_dashboard_filters: saved_dashboard_filters)
    end
  end

  def create(conn, %{"saved_dashboard_filter" => saved_dashboard_filter_params}) do
    with {:ok, %SavedDashboardFilter{} = saved_dashboard_filter} <- DashboardConfiguration.create_or_update_saved_dashboard_filter(saved_dashboard_filter_params, conn.assigns.current_user, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.saved_dashboard_filter_path(conn, :show, saved_dashboard_filter))
      |> render("show.json", saved_dashboard_filter: saved_dashboard_filter)
    end
  end

  def show(conn, %{"id" => id}) do
    saved_dashboard_filter = DashboardConfiguration.get_saved_dashboard_filter!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", saved_dashboard_filter: saved_dashboard_filter)
  end

  # def update(conn, %{"id" => id, "saved_dashboard_filter" => saved_dashboard_filter_params}) do
  #   saved_dashboard_filter = DashboardConfiguration.get_saved_dashboard_filter!(id)

  #   with {:ok, %SavedDashboardFilter{} = saved_dashboard_filter} <- DashboardConfiguration.update_saved_dashboard_filter(saved_dashboard_filter, saved_dashboard_filter_params) do
  #     render(conn, "show.json", saved_dashboard_filter: saved_dashboard_filter)
  #   end
  # end

  def delete(conn, %{"id" => id}) do
    saved_dashboard_filter = DashboardConfiguration.get_saved_dashboard_filter!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %SavedDashboardFilter{}} <- DashboardConfiguration.delete_saved_dashboard_filter(saved_dashboard_filter, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
