defmodule Inconn2ServiceWeb.UserController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Staff
  alias Inconn2Service.Staff.User

  action_fallback Inconn2ServiceWeb.FallbackController

  # def index(conn, _params) do
  #   users = Staff.list_users(conn.assigns.sub_domain_prefix)
  #   render(conn, "index.json", users: users)
  # end

  def index(conn, _params) do
    username = Map.get(conn.query_params, "username", nil)

    if username != nil do
      user = Staff.get_user_by_username(username, conn.assigns.sub_domain_prefix)
      render(conn, "show.json", user: user)
    else
      users = Staff.list_users(conn.assigns.sub_domain_prefix)
      render(conn, "index.json", users: users)
    end
  end

  # def create(conn, %{"user" => user_params}) do
  #   with {:ok, %User{} = user} <- Staff.create_user(user_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("user", Routes.user_path(conn, :show, user))
  #     |> render("show.json", user: user)
  #   end
  # end
  #
  # def update(conn, %{"id" => id, "user" => user_params}) do
  #   user = Staff.get_user!(id, conn.assigns.sub_domain_prefix)
  #
  #   with {:ok, %User{} = user} <-
  #          Staff.update_user(user, user_params, conn.assigns.sub_domain_prefix) do
  #     render(conn, "show.json", user: user)
  #   end
  # end

  def change_password(conn, %{"credential" => credentials}) do
    case Staff.change_user_password(conn.assigns.current_user, credentials, conn.assigns.sub_domain_prefix) do
      {:ok, user} ->
        render(conn, "success.json", user: user)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(Inconn2ServiceWeb.ChangesetView)
        |> render("error.json", changeset: changeset)

      {:error, reason} ->
        conn
        |> put_status(401)
        |> render("error.json", %{error: reason})
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Staff.get_user!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %User{}} <- Staff.delete_user(user, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
