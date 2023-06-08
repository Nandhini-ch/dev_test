defmodule Inconn2ServiceWeb.SiteController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.Site

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    sites = AssetConfig.list_sites(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index_with_zone.json", sites: sites)
  end

  def index_for_user(conn, _params) do
    sites = AssetConfig.list_sites_for_user(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", sites: sites)
  end

  def create(conn, %{"site" => site_params}) do
    with {:ok, %Site{} = site} <-
           AssetConfig.create_site(site_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.site_path(conn, :show, site))
      |> render("show.json", site: site)
    end
  end

  def show(conn, %{"id" => id}) do
    site = AssetConfig.get_site!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", site: site)
  end

  def update(conn, %{"id" => id, "site" => site_params}) do
    site = AssetConfig.get_site!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Site{} = site} <-
           AssetConfig.update_site(site, site_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", site: site)
    end
  end

  def delete(conn, %{"id" => id}) do
    site = AssetConfig.get_site!(id, conn.assigns.sub_domain_prefix)

    with {:deleted, _} <- AssetConfig.delete_site(site, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

  def activate_site(conn, %{"id" => id}) do
    site = AssetConfig.get_site!(id, conn.assigns.sub_domain_prefix)
    with {:ok, %Site{} = site} <-
      AssetConfig.update_site_active_status(site, %{"active" => true}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", site: site)
    end
  end

  def deactivate_site(conn, %{"id" => id}) do
    site = AssetConfig.get_site!(id, conn.assigns.sub_domain_prefix)
    with {:ok, %Site{} = site} <-
      AssetConfig.update_site_active_status(site, %{"active" => false}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", site: site)
    end
  end
end
