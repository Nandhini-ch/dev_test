defmodule Inconn2ServiceWeb.SiteView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.SiteView

  def render("index.json", %{sites: sites}) do
    %{data: render_many(sites, SiteView, "site.json")}
  end

  def render("show.json", %{site: site}) do
    %{data: render_one(site, SiteView, "site.json")}
  end

  def render("site.json", %{site: site}) do
    %{id: site.id,
      name: site.name,
      description: site.description,
      branch: site.branch,
      area: site.area,
      lattitude: site.lattitude,
      longitiude: site.longitiude,
      radius: site.radius}
  end
end
