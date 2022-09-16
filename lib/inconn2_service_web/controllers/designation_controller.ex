defmodule Inconn2ServiceWeb.DesignationController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Staff
  alias Inconn2Service.Staff.Designation

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    designations = Staff.list_designations(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", designations: designations)
  end

  def create(conn, %{"designation" => designation_params}) do
    with {:ok, %Designation{} = designation} <- Staff.create_designation(designation_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.designation_path(conn, :show, designation))
      |> render("show.json", designation: designation)
    end
  end

  def show(conn, %{"id" => id}) do
    designation = Staff.get_designation!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", designation: designation)
  end

  def update(conn, %{"id" => id, "designation" => designation_params}) do
    designation = Staff.get_designation!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Designation{} = designation} <- Staff.update_designation(designation, designation_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", designation: designation)
    end
  end

  def delete(conn, %{"id" => id}) do
    designation = Staff.get_designation!(id, conn.assigns.sub_domain_prefix)

    with {:deleted, _} <- Staff.delete_designation(designation, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
