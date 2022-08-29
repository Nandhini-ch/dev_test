defmodule Inconn2ServiceWeb.UserWidgetConfigController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.DashboardConfiguration
  alias Inconn2Service.DashboardConfiguration.UserWidgetConfig

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    user_widget_configs = DashboardConfiguration.list_user_widget_configs(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", user_widget_configs: user_widget_configs)
  end

  def create(conn, %{"user_widget_config" => user_widget_config_params}) do
    with {:ok, %UserWidgetConfig{} = user_widget_config} <- DashboardConfiguration.create_user_widget_config(user_widget_config_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_widget_config_path(conn, :show, user_widget_config))
      |> render("show.json", user_widget_config: user_widget_config)
    end
  end

  def show(conn, %{"id" => id}) do
    user_widget_config = DashboardConfiguration.get_user_widget_config!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", user_widget_config: user_widget_config)
  end

  def update(conn, %{"id" => id, "user_widget_config" => user_widget_config_params}) do
    user_widget_config = DashboardConfiguration.get_user_widget_config!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %UserWidgetConfig{} = user_widget_config} <- DashboardConfiguration.update_user_widget_config(user_widget_config, user_widget_config_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", user_widget_config: user_widget_config)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_widget_config = DashboardConfiguration.get_user_widget_config!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %UserWidgetConfig{}} <- DashboardConfiguration.delete_user_widget_config(user_widget_config, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
