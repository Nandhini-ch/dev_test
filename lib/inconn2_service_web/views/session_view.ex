defmodule Inconn2ServiceWeb.SessionView do
  use Inconn2ServiceWeb, :view

  def render("success.json", %{token: token, current_user: user}) do
    %{
      result: "success",
      token: token,
      current_user: %{
        id: user.id,
        username: user.username,
        party_id: user.party_id,
        role_id: user.role_id
      }
    }
  end

  # def render("failure.json", %{error: params}) do
  # %{result: params}
  # end

  def render("error.json", %{error: error_message}) do
    %{errors: %{detail: [error_message]}}
  end
end
