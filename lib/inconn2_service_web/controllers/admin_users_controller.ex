defmodule Inconn2ServiceWeb.AdminUserController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Common
  alias Inconn2Service.Common.AdminUser

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    admin_user = Common.list_admin_user()
    render(conn, "index.json", admin_user: admin_user)
  end

  def create(conn, %{"admin_user" => admin_user_params}) do
    with {:ok, %AdminUser{} = admin_user} <- Common.create_admin_user(admin_user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.admin_user_path(conn, :show, admin_user))
      |> render("show.json", admin_user: admin_user)
    end
  end

  def show(conn, %{"id" => id}) do
    admin_user = Common.get_admin_user!(id)
    render(conn, "show.json", admin_user: admin_user)
  end

  def update(conn, %{"id" => id, "admin_user" => admin_user_params}) do
    admin_user = Common.get_admin_user!(id)

    with {:ok, %AdminUser{} = admin_user} <- Common.update_admin_user(admin_user, admin_user_params) do
      render(conn, "show.json", admin_user: admin_user)
    end
  end

  def delete(conn, %{"id" => id}) do
    admin_user = Common.get_admin_user!(id)

    with {:ok, %AdminUser{}} <- Common.delete_admin_user(admin_user) do
      send_resp(conn, :no_content, "")
    end
  end
end
