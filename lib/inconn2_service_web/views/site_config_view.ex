defmodule Inconn2ServiceWeb.SiteConfigView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.SiteConfigView

  def render("index.json", %{site_config: site_config}) do
    %{data: render_many(site_config, SiteConfigView, "site_config.json")}
  end

  def render("show.json", %{site_config: site_config}) do
    %{data: render_one(site_config, SiteConfigView, "site_config.json")}
  end

  def render("site_config.json", %{site_config: site_config}) do
    %{id: site_config.id,
      site_id: site_config.site_id,
      type: site_config.type,
      config: site_config.config}
  end
end
