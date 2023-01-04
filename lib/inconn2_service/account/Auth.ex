defmodule Inconn2Service.Account.Auth do
  alias Inconn2Service.Staff
  import Comeonin

  # def authenticate(username, password, prefix) do
  #   user = Staff.get_user_by_username(username, prefix)

  #   case IO.inspect(check_password(password, user)) do
  #     {:error, msg} ->
  #       # IO.inspect(msg)
  #       # {:error, :invalid_credentials}
  #       {:error, msg}

  #     {:ok, user} ->
  #       {:ok, user}
  #   end
  # end

  def authenticate(username, password, prefix) do
    user = Staff.get_user_by_username(username, prefix)

    cond do
     is_nil(user) || !user.active -> {:error, "user does not exist"}
     user -> check_password(password, user)
     true -> {:error, "Incorrect Password"}
    end
  end

  def check_password(nil, _) do
    false
  end

  def check_password(password, user) do
    user
    |> Argon2.check_pass(password, hash_key: :password_hash)
  end
end
