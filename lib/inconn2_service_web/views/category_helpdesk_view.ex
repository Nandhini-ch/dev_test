defmodule Inconn2ServiceWeb.CategoryHelpdeskView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{CategoryHelpdeskView, SiteView, WorkrequestCategoryView, UserView}

  def render("index.json", %{category_helpdesks: category_helpdesks}) do
    %{data: render_many(category_helpdesks, CategoryHelpdeskView, "category_helpdesk.json")}
  end

  def render("show.json", %{category_helpdesk: category_helpdesk}) do
    %{data: render_one(category_helpdesk, CategoryHelpdeskView, "category_helpdesk.json")}
  end

  def render("category_helpdesk.json", %{category_helpdesk: category_helpdesk}) do
    %{id: category_helpdesk.id,
      user: render_one(category_helpdesk.user, UserView, "user_without_org_unit.json"),
      site: render_one(category_helpdesk.site, SiteView, "site.json"),
      workrequest_category: render_one(category_helpdesk.workrequest_category, WorkrequestCategoryView, "workrequest_category.json")}
  end
end
