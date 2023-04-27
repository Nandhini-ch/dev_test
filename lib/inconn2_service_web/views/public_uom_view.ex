defmodule Inconn2ServiceWeb.PublicUomView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.PublicUomView

  def render("index.json", %{public_uoms: public_uoms}) do
    %{data: render_many(public_uoms, PublicUomView, "public_uom.json")}
  end

  def render("show.json", %{public_uom: public_uom}) do
    %{data: render_one(public_uom, PublicUomView, "public_uom.json")}
  end

  def render("public_uom.json", %{public_uom: public_uom}) do
    %{id: public_uom.id,
      uom_category: public_uom.uom_category,
      uom_unit: public_uom.uom_unit,
      description: public_uom.description}
  end
end
