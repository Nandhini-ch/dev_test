defmodule Inconn2ServiceWeb.WorkrequestCategoryView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{WorkrequestCategoryView, WorkrequestSubcategoryView, UserView}

  def render("index.json", %{workrequest_categories: workrequest_categories}) do
    %{data: render_many(workrequest_categories, WorkrequestCategoryView, "workrequest_category.json")}
  end


  def render("index_with_helpdesk_user.json", %{workrequest_categories: workrequest_categories}) do
    %{data: render_many(workrequest_categories, WorkrequestCategoryView, "workrequest_category_with_helpdesk_user.json")}
  end

  def render("show.json", %{workrequest_category: workrequest_category}) do
    %{data: render_one(workrequest_category, WorkrequestCategoryView, "workrequest_category.json")}
  end

  def render("workrequest_category.json", %{workrequest_category: workrequest_category}) do
    %{id: workrequest_category.id,
      name: workrequest_category.name,
      description: workrequest_category.description,
      workrequest_subcategories: render_many(workrequest_category.workrequest_subcategories, WorkrequestSubcategoryView, "workrequest_subcategory.json")
    }
  end

  def render("workrequest_category_with_helpdesk_user.json", %{workrequest_category: workrequest_category}) do
    %{id: workrequest_category.id,
      name: workrequest_category.name,
      description: workrequest_category.description,
      helpdesk_users: render_many(workrequest_category.helpdesk_users, UserView, "user.json")
    }
  end

  def render("workrequest_category_without_preload.json", %{workrequest_category: workrequest_category}) do
    %{id: workrequest_category.id,
      name: workrequest_category.name,
      description: workrequest_category.description
    }
  end
end
