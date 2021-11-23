defmodule Inconn2ServiceWeb.RoleProfileController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Staff
  alias Inconn2Service.Staff.RoleProfile

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    role_profiles = Staff.list_role_profiles(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", role_profiles: role_profiles)
  end

  def create(conn, %{"role_profile" => role_profile_params}) do
    with {:ok, %RoleProfile{} = role_profile} <- Staff.create_role_profile(role_profile_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.role_profile_path(conn, :show, role_profile))
      |> render("show.json", role_profile: role_profile)
    end
  end

  def show(conn, %{"id" => id}) do
    role_profile = Staff.get_role_profile!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", role_profile: role_profile)
  end

  def update(conn, %{"id" => id, "role_profile" => role_profile_params}) do
    role_profile = Staff.get_role_profile!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %RoleProfile{} = role_profile} <- Staff.update_role_profile(role_profile, role_profile_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", role_profile: role_profile)
    end
  end

  def delete(conn, %{"id" => id}) do
    role_profile = Staff.get_role_profile!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %RoleProfile{}} <- Staff.delete_role_profile(role_profile, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
