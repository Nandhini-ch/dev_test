defmodule Inconn2ServiceWeb.RoleController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Staff
  alias Inconn2Service.Staff.Role

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    roles = Staff.list_roles()
    render(conn, "index.json", roles: roles)
  end

  def create(conn, %{"role" => role_params}) do
    with {:ok, %Role{} = role} <- Staff.create_role(role_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("Role", Routes.role_path(conn, :show, role))
      |> render("show.json", role: role)
    end
  end

  def show(conn, %{"id" => id}) do
    role = Staff.get_role!(id)
    render(conn, "show.json", role: role)
  end

  def update(conn, %{"id" => id, "role" => role_params}) do
    role = Staff.get_role!(id)

    with {:ok, %Role{} = role} <- Staff.update_role(role, role_params) do
      render(conn, "show.json", role: role)
    end
  end

  def delete(conn, %{"id" => id}) do
    role = Staff.get_role!(id)

    with {:ok, %Role{}} <- Staff.delete_role(role) do
      send_resp(conn, :no_content, "")
    end
  end
end
