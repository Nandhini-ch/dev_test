defmodule Inconn2ServiceWeb.SiteController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.Site

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    sites = AssetConfig.list_sites()
    render(conn, "index.json", sites: sites)
  end

  def create(conn, %{"site" => site_params}) do
    with {:ok, %Site{} = site} <- AssetConfig.create_site(site_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.site_path(conn, :show, site))
      |> render("show.json", site: site)
    end
  end

  def show(conn, %{"id" => id}) do
    site = AssetConfig.get_site!(id)
    render(conn, "show.json", site: site)
  end

  def update(conn, %{"id" => id, "site" => site_params}) do
    site = AssetConfig.get_site!(id)

    with {:ok, %Site{} = site} <- AssetConfig.update_site(site, site_params) do
      render(conn, "show.json", site: site)
    end
  end

  def delete(conn, %{"id" => id}) do
    site = AssetConfig.get_site!(id)

    with {:ok, %Site{}} <- AssetConfig.delete_site(site) do
      send_resp(conn, :no_content, "")
    end
  end
end
