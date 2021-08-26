defmodule Inconn2ServiceWeb.WorkorderTemplateController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkorderTemplate

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    workorder_templates = Workorder.list_workorder_templates(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", workorder_templates: workorder_templates)
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

    with {:ok, %WorkorderTemplate{} = workorder_template} <- Workorder.update_workorder_template(workorder_template, workorder_template_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", workorder_template: workorder_template)
    end
  end

  def delete(conn, %{"id" => id}) do
    workorder_template = Workorder.get_workorder_template!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderTemplate{}} <- Workorder.delete_workorder_template(workorder_template, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
