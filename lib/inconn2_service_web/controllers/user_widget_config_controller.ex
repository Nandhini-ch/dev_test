defmodule Inconn2ServiceWeb.UserWidgetConfigController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.DashboardConfiguration

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, params) do
    user_widget_configs = DashboardConfiguration.list_user_widget_configs(params, conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", user_widget_configs: user_widget_configs)
  end

  def create_or_update(conn, %{"user_widget_configs" => user_widget_config_params}) do
    with {:ok, user_widget_configs} <- DashboardConfiguration.create_or_update_configs(user_widget_config_params, conn.assigns.current_user, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> render("index.json", user_widget_configs: user_widget_configs)
    end
  end

  def show(conn, %{"id" => id}) do
    user_widget_config = DashboardConfiguration.get_user_widget_config!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", user_widget_config: user_widget_config)
  end

end
