defmodule Inconn2ServiceWeb.SupplierView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.SupplierView

  def render("index.json", %{suppliers: suppliers}) do
    %{data: render_many(suppliers, SupplierView, "supplier.json")}
  end

  def render("show.json", %{supplier: supplier}) do
    %{data: render_one(supplier, SupplierView, "supplier.json")}
  end

  def render("supplier.json", %{supplier: supplier}) do
    %{id: supplier.id,
      name: supplier.name}
  end
end
