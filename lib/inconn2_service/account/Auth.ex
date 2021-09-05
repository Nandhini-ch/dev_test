defmodule Inconn2Service.Account.Auth do
  alias Inconn2Service.Staff
  import Comeonin

  def authenticate(username, password, prefix) do
    user = Staff.get_user_by_email(username, prefix)

    case IO.inspect(check_password(password, user)) do
      {:error, _msg} -> {:error, :invalid_credentials}
      {:ok, user} -> {:ok, user}
    end
  end

  defp check_password(nil, _) do
    false
  end

  defp check_password(password, user) do
    user
    |> Argon2.check_pass(password, hash_key: :password_hash)
  end
end
