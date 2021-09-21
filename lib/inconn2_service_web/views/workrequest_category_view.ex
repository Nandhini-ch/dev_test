defmodule Inconn2ServiceWeb.WorkrequestCategoryView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.WorkrequestCategoryView

  def render("index.json", %{workrequest_categories: workrequest_categories}) do
    %{data: render_many(workrequest_categories, WorkrequestCategoryView, "workrequest_category.json")}
  end

  def render("show.json", %{workrequest_category: workrequest_category}) do
    %{data: render_one(workrequest_category, WorkrequestCategoryView, "workrequest_category.json")}
  end

  def render("workrequest_category.json", %{workrequest_category: workrequest_category}) do
    %{id: workrequest_category.id,
      name: workrequest_category.name,
      description: workrequest_category.description}
  end
end
