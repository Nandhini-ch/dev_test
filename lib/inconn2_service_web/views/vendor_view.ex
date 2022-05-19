defmodule Inconn2ServiceWeb.VendorView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.VendorView

  def render("index.json", %{vendors: vendors}) do
    %{data: render_many(vendors, VendorView, "vendor.json")}
  end

  def render("show.json", %{vendor: vendor}) do
    %{data: render_one(vendor, VendorView, "vendor.json")}
  end

  def render("vendor.json", %{vendor: vendor}) do
    %{id: vendor.id,
      name: vendor.name,
      description: vendor.description,
      register_no: vendor.register_no,
      contact: vendor.contact}
  end
end
