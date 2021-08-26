defmodule Inconn2ServiceWeb.PartyView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.PartyView

  def render("index.json", %{parties: parties}) do
    %{data: render_many(parties, PartyView, "party.json")}
  end

  def render("show.json", %{party: party}) do
    %{data: render_one(party, PartyView, "party.json")}
  end

  def render("party.json", %{party: party}) do
    %{id: party.id,
      org_name: party.org_name,
      party_type: party.party_type,
      contract_start_date: party.contract_start_date,
      contract_end_date: party.contract_end_date,
      service_type: party.service_type,
      licensee: party.licensee,
      service_id: party.service_id,
      license_no: party.license_no,
      preferred_service: party.preferred_service,
      rates_per_hour: party.rates_per_hour,
      type_of_maintenance: party.type_of_maintenance}
  end
end
