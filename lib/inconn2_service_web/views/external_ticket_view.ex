defmodule Inconn2ServiceWeb.ExternalTicketView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{ExternalTicketView, WorkRequestView, WorkrequestCategoryView, WorkrequestSubcategoryView}

  def render("index.json", %{work_requests: work_requests}) do
    %{data: render_many(work_requests, WorkRequestView, "external_work_request.json")}
  end

  def render("show.json", %{work_request: work_request}) do
    %{data: render_one(work_request, WorkRequestView, "external_work_request.json")}
  end

  def render("index_categories.json", %{workrequest_categories: workrequest_categories}) do
    %{data: render_many(workrequest_categories, WorkrequestCategoryView, "workrequest_category.json")}
  end

  def render("index_subcategories.json", %{workrequest_subcategories: workrequest_subcategories}) do
    %{data: render_many(workrequest_subcategories, WorkrequestSubcategoryView, "workrequest_subcategory.json")}
  end

end
