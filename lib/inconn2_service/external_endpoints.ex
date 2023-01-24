defmodule Inconn2Service.ExternalEndpoints do

  alias Inconn2Service.Guardian

  def get_resource_from_token(token) do
    result = Guardian.resource_from_token(token)
    case result do
      {:ok, user, claims} ->
        %{
          message: "success",
          user: %{
            name: get_name_for_view(user),
            username: user.username
          },
          prefix: String.split(claims["sub"], "@") |> List.last()
        }
      _ ->
        %{message: "error"}
    end
  end

  defp get_name_for_view(%Inconn2Service.Staff.User{} = user) do
    "#{user.first_name} #{user.last_name}"
  end

  defp get_name_for_view(%Inconn2Service.Common.AdminUser{} = user) do
   user.full_name
  end

end
