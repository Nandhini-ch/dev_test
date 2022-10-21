defmodule Inconn2ServiceWeb.ConversionView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{ConversionView, UnitOfMeasurementView, UomCategoryView}

  def render("index.json", %{conversions: conversions}) do
    %{data: render_many(conversions, ConversionView, "conversion.json")}
  end

  def render("show.json", %{conversion: conversion}) do
    %{data: render_one(conversion, ConversionView, "conversion.json")}
  end

  def render("conversion.json", %{conversion: conversion}) do
    %{id: conversion.id,
      from_unit_of_measurement_id: conversion.from_unit_of_measurement_id,
      from_unit_of_measurement: render_one(conversion.from_unit_of_measurement, UnitOfMeasurementView, "unit_of_measurement_without_category.json"),
      to_unit_of_measurement_id: conversion.to_unit_of_measurement_id,
      to_unit_of_measurement: render_one(conversion.to_unit_of_measurement, UnitOfMeasurementView, "unit_of_measurement_without_category.json"),
      uom_category_id: conversion.uom_category_id,
      uom_category: render_one(conversion.uom_category, UomCategoryView, "uom_category.json"),
      multiplication_factor: conversion.multiplication_factor}
  end
end
