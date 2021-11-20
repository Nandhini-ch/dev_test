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
      nature_of_business: supplier.nature_of_business,
      registration_no: supplier.registration_no,
      gst_no: supplier.gst_no,
      website: supplier.website,
      remarks: supplier.remarks,
      contact: render_one(supplier.contact, AddressContactView, "contact.json")
    }
  end
end
