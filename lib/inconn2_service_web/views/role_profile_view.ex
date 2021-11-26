defmodule Inconn2ServiceWeb.RoleProfileView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.RoleProfileView

  def render("index.json", %{role_profiles: role_profiles}) do
    %{data: render_many(role_profiles, RoleProfileView, "role_profile.json")}
  end

  def render("show.json", %{role_profile: role_profile}) do
    %{data: render_one(role_profile, RoleProfileView, "role_profile.json")}
  end

  def render("role_profile.json", %{role_profile: role_profile}) do
    %{id: role_profile.id,
      name: role_profile.name,
      code: role_profile.code,
      permissions: role_profile.permissions}
  end
end
