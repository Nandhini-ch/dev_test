defmodule Inconn2ServiceWeb.SiteConfigController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.SiteConfig

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, query_params) do
    site_config = AssetConfig.get_site_config_by_site_id(query_params["site_id"], conn.assigns.sub_domain_prefix)
    render(conn, "index.json", site_config: site_config)
  end

  def create(conn, %{"site_config" => site_config_params}) do
    with {:ok, %SiteConfig{} = site_config} <- AssetConfig.create_site_config(site_config_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.site_config_path(conn, :show, site_config))
      |> render("show.json", site_config: site_config)
    end
  end

  def show(conn, %{"id" => id}) do
    site_config = AssetConfig.get_site_config!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", site_config: site_config)
  end

  def update(conn, %{"id" => id, "site_config" => site_config_params}) do
    site_config = AssetConfig.get_site_config!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %SiteConfig{} = site_config} <- AssetConfig.update_site_config(site_config, site_config_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", site_config: site_config)
    end
  end

  def delete(conn, %{"id" => id}) do
    site_config = AssetConfig.get_site_config!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %SiteConfig{}} <- AssetConfig.delete_site_config(site_config, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
