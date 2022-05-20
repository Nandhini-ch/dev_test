defmodule Inconn2ServiceWeb.ServiceBranchView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{ServiceBranchView, AddressContactView}

  def render("index.json", %{service_branches: service_branches}) do
    %{data: render_many(service_branches, ServiceBranchView, "service_branch.json")}
  end

  def render("show.json", %{service_branch: service_branch}) do
    %{data: render_one(service_branch, ServiceBranchView, "service_branch.json")}
  end

  def render("service_branch.json", %{service_branch: service_branch}) do
    %{id: service_branch.id,
      region: service_branch.region,
      address: render_one(service_branch.address, AddressContactView, "address.json"),
      contact: render_one(service_branch.contact, AddressContactView, "contact.json")}
  end
end
