defmodule Inconn2ServiceWeb.PartyView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.PartyView
  alias Inconn2ServiceWeb.AddressContactView

  def render("index.json", %{parties: parties}) do
    %{data: render_many(parties, PartyView, "party.json")}
  end

  def render("show.json", %{party: party}) do
    %{data: render_one(party, PartyView, "party.json")}
  end

  def render("party.json", %{party: party}) do
    %{
      id: party.id,
      company_name: party.company_name,
      party_type: party.party_type,
      licensee: party.licensee,
      license_no: party.license_no,
      pan_number: party.pan_number,
      address: render_one(party.address, AddressContactView, "address.json"),
      contact: render_one(party.contact, AddressContactView, "contact.json")
    }
  end
end
