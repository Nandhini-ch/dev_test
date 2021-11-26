defmodule Inconn2ServiceWeb.RoleView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{RoleView, RoleProfileView}

  def render("index.json", %{roles: roles}) do
    %{data: render_many(roles, RoleView, "role.json")}
  end

  def render("show.json", %{role: role}) do
    %{data: render_one(role, RoleView, "role.json")}
  end

  def render("role.json", %{role: role}) do
    %{id: role.id,
      name: role.name,
      description: role.description,
      permissions: role.permissions,
      role_profile: render_one(role.role_profile, RoleProfileView, "role_profile.json")
    }
  end
end
