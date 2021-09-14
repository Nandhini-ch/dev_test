defmodule Inconn2ServiceWeb.SessionView do
  use Inconn2ServiceWeb, :view

  def render("success.json", %{token: token}) do
    %{
      result: "success",
      token: token
    }
  end

  # def render("failure.json", %{error: params}) do
  # %{result: params}
  # end

  def render("error.json", %{error: error_message}) do
    %{errors: %{detail: [error_message]}}
  end

  def render("current_user.json", %{current_user: current_user, party: party}) do
    %{
      data: %{
        id: current_user.id,
        username: current_user.username,
        party_id: current_user.party_id,
        role_id: current_user.role_id,
        licensee: party.licensee,
        party_type: party.party_type
      }
    }
  end
end
