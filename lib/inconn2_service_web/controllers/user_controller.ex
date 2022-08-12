defmodule Inconn2ServiceWeb.UserController do
  use Inconn2ServiceWeb, :controller
  # plug :correct_user when action in [:change_password]

  alias Inconn2Service.Staff
  alias Inconn2Service.Confirmation
  alias Inconn2Service.Staff.User

  action_fallback Inconn2ServiceWeb.FallbackController

  # def index(conn, _params) do
  #   users = Staff.list_users(conn.assigns.sub_domain_prefix)
  #   render(conn, "index.json", users: users)
  # end

  def index(conn, _params) do
    username = Map.get(conn.query_params, "username", nil)

    if username != nil do
      user = Staff.get_user_by_username(username, conn.assigns.current_user, conn.assigns.sub_domain_prefix)
      render(conn, "show.json", user: user)
    else
      users = Staff.list_users(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
      render(conn, "index.json", users: users)
    end
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Staff.create_user(user_params, conn.assigns.sub_domain_prefix) do
       conn
       |> put_status(:created)
       |> put_resp_header("user", Routes.user_path(conn, :show, user))
       |> render("show.json", user: user)
     end
  end

  def show(conn, %{"id" => id}) do
    user = Staff.get_user!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
   user = Staff.get_user!(id, conn.assigns.sub_domain_prefix)

   with {:ok, %User{} = user} <-
          Staff.update_user(user, user_params, conn.assigns.sub_domain_prefix) do
     render(conn, "show.json", user: user)
   end
 end

  def change_password(conn, %{"credential" => credentials}) do
    if conn.assigns.current_user.id == String.to_integer(conn.params["id"]) do
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
    else
      conn
      |> put_status(404)
      |> render("error.json", %{error: "Cannot change another users password"})
    end
  end

  def forgot_password(conn, %{"credentials" => credentials}) do
    case Staff.get_user_by_username_for_otp(credentials["username"], conn.assigns.sub_domain_prefix) do
      {:ok, user} ->
        Confirmation.create_forgot_password_otp(
          %{
            "user_id" => user.id,
            "username" => user.username,
            # "otp" => Enum.random(1000..9999), uncomment when is api is working properly
            "otp" => 1234,
            "created_date_time" => NaiveDateTime.utc_now()
          },
          conn.assigns.sub_domain_prefix
        )
        # text = Inconn2Service.SmsTemplates.forgot_password_template(otp_entry.otp)
        #The above line is supposed to send SMS to the user, it is commented dut to compications with the api.
        render(conn, "user.json", user: user)

      {:error, reason} ->
        conn
        |> put_status(422)
        |> render("general_error.json", %{error: reason})
    end
  end

  def confirm_otp(conn, %{"credential" => credential}) do
    case Confirmation.confirm_otp(credential["user_id"], credential["otp"], conn.assigns.sub_domain_prefix) do
      {:ok, user} ->
        render(conn, "user.json", user: user)

      {:error, reason} ->
        conn
        |> put_status(422)
        |> render("general_error.json", %{error: reason})
    end
  end

  def reset_password(conn, %{"credential" => user_params}) do
    user = Staff.get_user!(user_params["user_id"], conn.assigns.sub_domain_prefix)
    otp_entry = Confirmation.get_forgot_password_otp_by_user_id(user_params["user_id"], conn.assigns.sub_domain_prefix)
    cond do
      otp_entry && otp_entry.validated ->
        with {:ok, %User{} = user} <- Staff.reset_user_password(user, user_params, conn.assigns.sub_domain_prefix) do
          Confirmation.delete_forgot_password_otp(otp_entry, conn.assigns.sub_domain_prefix)
          render(conn, "show.json", user: user)
        end

      true ->
        conn
        |> put_status(422)
        |> render("general_error.json", %{error: "Please try forgot password flow again"})
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Staff.get_user!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %User{}} <- Staff.delete_user(user, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

#   defp correct_user(conn, _params) do
#     IO.inspect(is_binary(conn.params["id"]))
#     if conn.assigns.current_user.id == String.to_integer(conn.params["id"]) do
#       conn
#     else
#       conn
#       |> put_status(404)
#       |> render("error.json", %{error: "Cannot change another users password"})
#     end
#   end
end
