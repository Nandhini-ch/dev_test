defmodule Inconn2Service.Account.Auth do
  alias Inconn2Service.Staff
  alias Inconn2Service.Common
  import Comeonin

  def authenticate(username, password, prefix) do
    user = get_user(prefix, username)

    case IO.inspect(check_password(password, user)) do
      {:error, msg} ->
        # IO.inspect(msg)
        # {:error, :invalid_credentials}
        {:error, msg}

      {:ok, user} ->
        {:ok, user}
    end
  end

  defp get_user("inc_admin", username), do: Common.get_admin_user_by_username(username)
  defp get_user(prefix, username), do: Staff.get_user_by_username(username, prefix)


  def check_password(nil, _) do
    false
  end

  def check_password(password, user) do
    user
    |> Argon2.check_pass(password, hash_key: :password_hash)
  end
end
