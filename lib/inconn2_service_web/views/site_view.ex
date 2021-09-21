defmodule Inconn2ServiceWeb.SiteView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.SiteView
  alias Inconn2ServiceWeb.AddressContactView

  def render("index.json", %{sites: sites}) do
    %{data: render_many(sites, SiteView, "site.json")}
  end

  def render("show.json", %{site: site}) do
    %{data: render_one(site, SiteView, "site.json")}
  end

  def render("site.json", %{site: site}) do
    %{
      id: site.id,
      name: site.name,
      description: site.description,
      branch: site.branch,
      area: site.area,
      latitude: site.latitude,
      longitude: site.longitude,
      time_zone: site.time_zone,
      fencing_radius: site.fencing_radius,
      site_code: site.site_code,
      party_id: site.party_id,
      address: render_one(site.address, AddressContactView, "address.json"),
      contact: render_one(site.contact, AddressContactView, "contact.json")
    }
  end
end
