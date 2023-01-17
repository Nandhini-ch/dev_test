defmodule Inconn2ServiceWeb.AdminUserView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.AdminUserView

  def render("index.json", %{admin_user: admin_user}) do
    %{data: render_many(admin_user, AdminUserView, "admin_user.json")}
  end

  def render("show.json", %{admin_user: admin_user}) do
    %{data: render_one(admin_user, AdminUserView, "admin_user.json")}
  end

  def render("admin_user.json", %{admin_user: admin_user}) do
    %{id: admin_user.id,
      full_name: admin_user.full_name,
      username: admin_user.username,
      phone_no: admin_user.phone_no}
  end
end
