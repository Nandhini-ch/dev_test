defmodule Inconn2ServiceWeb.UnitOfMeasurementView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.UnitOfMeasurementView

  def render("index.json", %{unit_of_measurements: unit_of_measurements}) do
    %{data: render_many(unit_of_measurements, UnitOfMeasurementView, "unit_of_measurement.json")}
  end

  def render("show.json", %{unit_of_measurement: unit_of_measurement}) do
    %{data: render_one(unit_of_measurement, UnitOfMeasurementView, "unit_of_measurement.json")}
  end

  def render("unit_of_measurement.json", %{unit_of_measurement: unit_of_measurement}) do
    %{id: unit_of_measurement.id,
      name: unit_of_measurement.name,
      unit: unit_of_measurement.unit,
      uom_category_id: unit_of_measurement.uom_category_id}
  end
end
