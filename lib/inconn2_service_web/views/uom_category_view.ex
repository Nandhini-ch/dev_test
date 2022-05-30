defmodule Inconn2ServiceWeb.UomCategoryView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.UomCategoryView

  def render("index.json", %{uom_categories: uom_categories}) do
    %{data: render_many(uom_categories, UomCategoryView, "uom_category.json")}
  end

  def render("show.json", %{uom_category: uom_category}) do
    %{data: render_one(uom_category, UomCategoryView, "uom_category.json")}
  end

  def render("uom_category.json", %{uom_category: uom_category}) do
    %{id: uom_category.id,
      name: uom_category.name,
      description: uom_category.description}
  end
end
