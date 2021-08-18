defmodule Inconn2ServiceWeb.LicenseeView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.LicenseeView
  alias Inconn2ServiceWeb.AddressContactView

  def render("index.json", %{licensees: licensees}) do
    %{data: render_many(licensees, LicenseeView, "licensee.json")}
  end

  def render("show.json", %{licensee: licensee}) do
    %{data: render_one(licensee, LicenseeView, "licensee.json")}
  end

  def render("licensee.json", %{licensee: licensee}) do
    %{id: licensee.id,
      company_name: licensee.company_name,
      business_type: licensee.business_type.name,
      address: render_one(licensee.address, AddressContactView, "address.json"),
      contact: render_one(licensee.contact, AddressContactView, "contact.json")
    }
  end

end
