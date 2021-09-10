defmodule Inconn2ServiceWeb.RoleView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.RoleView

  def render("index.json", %{roles: roles}) do
    %{data: render_many(roles, RoleView, "role.json")}
  end

  def render("show.json", %{role: role}) do
    %{data: render_one(role, RoleView, "role.json")}
  end

  def render("role.json", %{role: role}) do
    %{id: role.id,
      code: role.code,
      name: role.name}
  end
end
