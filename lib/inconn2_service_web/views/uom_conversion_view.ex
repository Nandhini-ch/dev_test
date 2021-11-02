defmodule Inconn2ServiceWeb.UomConversionView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.UomConversionView

  def render("index.json", %{uom_conversions: uom_conversions}) do
    %{data: render_many(uom_conversions, UomConversionView, "uom_conversion.json")}
  end

  def render("show.json", %{uom_conversion: uom_conversion}) do
    %{data: render_one(uom_conversion, UomConversionView, "uom_conversion.json")}
  end

  def render("convert.json", %{uom_conversion: uom_conversion}) do
    %{data: %{converted_value: uom_conversion.converted_value}}
  end

  def render("uom_conversion.json", %{uom_conversion: uom_conversion}) do
    %{id: uom_conversion.id,
      from_uom_id: uom_conversion.from_uom_id,
      to_uom_id: uom_conversion.to_uom_id,
      mult_factor: uom_conversion.mult_factor,
      inverse_factor: uom_conversion.inverse_factor}
  end
end
