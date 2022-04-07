defmodule Inconn2ServiceWeb.WorkRequestView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{WorkRequestView, WorkrequestCategoryView, WorkrequestSubcategoryView, LocationView, SiteView, UserView}

  def render("index.json", %{work_requests: work_requests}) do
    %{data: render_many(work_requests, WorkRequestView, "work_request.json")}
  end

  def render("index_for_actions.json", %{work_requests: work_requests}) do
    %{
      data:
        %{
          raised_by_me: render_many(work_requests.raised_by_me, WorkRequestView, "work_request.json"),
          to_be_closed: render_many(work_requests.to_be_closed, WorkRequestView, "work_request.json"),
          helpdesk: render_many(work_requests.helpdesk, WorkRequestView, "work_request.json")
        }
    }
  end

  def render("show.json", %{work_request: work_request}) do
    %{data: render_one(work_request, WorkRequestView, "work_request.json")}
  end

  def render("work_request.json", %{work_request: work_request}) do
    %{id: work_request.id,
      site: render_one(work_request.site, SiteView, "site.json"),
      workrequest_category: render_one(work_request.workrequest_category, WorkrequestCategoryView, "workrequest_category_without_preload.json"),
      workrequest_subcategory: render_one(work_request.workrequest_subcategory, WorkrequestSubcategoryView, "workrequest_subcategory.json"),
      location: render_one(work_request.location, LocationView, "location.json"),
      asset_id: work_request.asset_id,
      asset_type: work_request.asset_type,
      asset: render_one(work_request.asset, WorkRequestView, "asset.json"),
      description: work_request.description,
      priority: work_request.priority,
      request_type: work_request.request_type,
      time_of_requirement: work_request.time_of_requirement,
      raised_date_time: work_request.raised_date_time,
      requested_user: render_one(work_request.requested_user, UserView, "user_without_org_unit.json"),
      assigned_user: render_one(work_request.assigned_user, UserView, "user_without_org_unit.json"),
      attachment_type: work_request.attachment_type,
      status: work_request.status,
      is_approvals_required: work_request.is_approvals_required,
      approvals_required: work_request.approvals_required,
      approvals_required_user: render_many(work_request.approvals_required_user, UserView, "user_without_org_unit.json"),
      response_tat: work_request.response_tat,
      resolution_tat: work_request.resolution_tat,
      work_order_id: work_request.work_order_id}
  end

  def render("asset.json", %{work_request: asset}) do
    %{
      id: asset.id,
      name: asset.name
    }
  end

  def render("work_request_mobile.json", %{work_request: work_request}) do
    %{id: work_request.id,
      # site: render_one(work_request.site, SiteView, "site.json"),
      # workrequest_category: render_one(work_request.workrequest_category, WorkrequestCategoryView, "workrequest_category_without_preload.json"),
      # workrequest_subcategory: render_one(work_request.workrequest_subcategory, WorkrequestSubcategoryView, "workrequest_subcategory.json"),
      location: render_one(work_request.location, LocationView, "location.json"),
      asset_id: work_request.asset_id,
      asset_type: work_request.asset_type,
      description: work_request.description,
      priority: work_request.priority,
      request_type: work_request.request_type,
      time_of_requirement: work_request.time_of_requirement,
      raised_date_time: work_request.raised_date_time,
      requested_user: render_one(work_request.requested_user, UserView, "user_without_org_unit.json"),
      assigned_user: render_one(work_request.assigned_user, UserView, "user_without_org_unit.json"),
      attachment_type: work_request.attachment_type,
      status: work_request.status,
      is_approvals_required: work_request.is_approvals_required,
      approvals_required: work_request.approvals_required,
      work_order_id: work_request.work_order_id}
  end
end
