defmodule Inconn2ServiceWeb.OrgUnitController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Staff
  alias Inconn2Service.Staff.OrgUnit

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, %{"party_id" => party_id}) do
    org_units = Staff.list_org_units(party_id, conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", org_units: org_units)
  end

  def tree(conn, %{"party_id" => party_id}) do
    org_units = Staff.list_org_units_tree(party_id, conn.assigns.sub_domain_prefix)
    render(conn, "tree.json", org_units: org_units)
  end

  def leaves(conn, %{"party_id" => party_id}) do
    org_units = Staff.list_org_units_leaves(party_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", org_units: org_units)
  end

  def create(conn, %{"org_unit" => org_unit_params}) do
    with {:ok, %OrgUnit{} = org_unit} <- Staff.create_org_unit(org_unit_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.org_unit_path(conn, :show, org_unit))
      |> render("show.json", org_unit: org_unit)
    end
  end

  def show(conn, %{"id" => id}) do
    org_unit = Staff.get_org_unit!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", org_unit: org_unit)
  end

  def update(conn, %{"id" => id, "org_unit" => org_unit_params}) do
    org_unit = Staff.get_org_unit!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %OrgUnit{} = org_unit} <- Staff.update_org_unit(org_unit, org_unit_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", org_unit: org_unit)
    end
  end

  def delete(conn, %{"id" => id}) do
    org_unit = Staff.get_org_unit!(id, conn.assigns.sub_domain_prefix)

    with {_, nil} <- Staff.delete_org_unit(org_unit, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
