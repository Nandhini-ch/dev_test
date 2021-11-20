defmodule Inconn2ServiceWeb.UOMView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.UOMView

  def render("index.json", %{uoms: uoms}) do
    %{data: render_many(uoms, UOMView, "uom.json")}
  end

  def render("show.json", %{uom: uom}) do
    %{data: render_one(uom, UOMView, "uom.json")}
  end

  def render("uom.json", %{uom: uom}) do
    %{id: uom.id,
      name: uom.name,
      symbol: uom.symbol,
      uom_type: uom.uom_type}
  end
end
