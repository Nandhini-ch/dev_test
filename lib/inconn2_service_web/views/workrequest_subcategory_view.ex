defmodule Inconn2ServiceWeb.WorkrequestSubcategoryView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{WorkrequestSubcategoryView, WorkrequestCategoryView}

  def render("index.json", %{workrequest_subcategories: workrequest_subcategories}) do
    %{data: render_many(workrequest_subcategories, WorkrequestSubcategoryView, "workrequest_subcategory.json")}
  end

  def render("show.json", %{workrequest_subcategory: workrequest_subcategory}) do
    %{data: render_one(workrequest_subcategory, WorkrequestSubcategoryView, "workrequest_subcategory.json")}
  end

  def render("workrequest_subcategory.json", %{workrequest_subcategory: workrequest_subcategory}) do
    %{id: workrequest_subcategory.id,
      name: workrequest_subcategory.name,
      description: workrequest_subcategory.description,
      workrequest_category: render_one(workrequest_subcategory.workrequest_category, WorkrequestCategoryView, "workrequest_category.json")}
  end
end
