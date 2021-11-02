defmodule Inconn2ServiceWeb.SupplierView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.SupplierView
  alias Inconn2ServiceWeb.AddressContactView

  def render("index.json", %{suppliers: suppliers}) do
    %{data: render_many(suppliers, SupplierView, "supplier.json")}
  end

  def render("show.json", %{supplier: supplier}) do
    %{data: render_one(supplier, SupplierView, "supplier.json")}
  end

  def render("supplier.json", %{supplier: supplier}) do
    %{id: supplier.id,
      name: supplier.name,
      description: supplier.description,
      contact: render_one(supplier.contact, AddressContactView, "contact.json")
    }
  end
end
