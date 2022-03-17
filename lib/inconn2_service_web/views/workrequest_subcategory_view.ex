defmodule Inconn2ServiceWeb.WorkrequestSubcategoryView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{WorkrequestSubcategoryView}

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
      response_tat: workrequest_subcategory.response_tat,
      resolution_tat: workrequest_subcategory.resolution_tat,
      workrequest_category_id: workrequest_subcategory.workrequest_category_id
    }
  end
end
