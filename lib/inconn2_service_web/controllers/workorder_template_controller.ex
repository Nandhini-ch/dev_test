defmodule Inconn2ServiceWeb.WorkorderTemplateController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkorderTemplate

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    workorder_templates = Workorder.list_workorder_templates(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", workorder_templates: workorder_templates)
  end

  def index_assets_and_schedules(conn, %{"site_id" => site_id, "workorder_template_id" => workorder_template_id}) do
    {assets, workorder_schedules} = Workorder.list_assets_and_schedules(site_id, workorder_template_id, conn.assigns.sub_domain_prefix)
    render(conn, "assets_and_schedules.json", assets: assets, workorder_schedules: workorder_schedules)
  end

  def create(conn, %{"workorder_template" => workorder_template_params}) do
    with {:ok, %WorkorderTemplate{} = workorder_template} <- Workorder.create_workorder_template(workorder_template_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.workorder_template_path(conn, :show, workorder_template))
      |> render("show.json", workorder_template: workorder_template)
    end
  end

  def show(conn, %{"id" => id}) do
    workorder_template = Workorder.get_workorder_template!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", workorder_template: workorder_template)
  end

  def update(conn, %{"id" => id, "workorder_template" => workorder_template_params}) do
    workorder_template = Workorder.get_workorder_template!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderTemplate{} = workorder_template} <- Workorder.update_workorder_template(workorder_template, workorder_template_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", workorder_template: workorder_template)
    end
  end

  def delete(conn, %{"id" => id}) do
    workorder_template = Workorder.get_workorder_template!(id, conn.assigns.sub_domain_prefix)

    with {:deleted, _} <- Workorder.delete_workorder_template(workorder_template, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      send_resp(conn, :no_content, "")
    end
  end

end
