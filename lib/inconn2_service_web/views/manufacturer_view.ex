defmodule Inconn2ServiceWeb.ManufacturerView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.ManufacturerView

  def render("index.json", %{manufacturers: manufacturers}) do
    %{data: render_many(manufacturers, ManufacturerView, "manufacturer.json")}
  end

  def render("show.json", %{manufacturer: manufacturer}) do
    %{data: render_one(manufacturer, ManufacturerView, "manufacturer.json")}
  end

  def render("manufacturer.json", %{manufacturer: manufacturer}) do
    %{id: manufacturer.id,
      name: manufacturer.name,
      register_no: manufacturer.register_no,
      description: manufacturer.description,
      contact: manufacturer.contact}
  end
end
