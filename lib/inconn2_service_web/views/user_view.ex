defmodule Inconn2ServiceWeb.UserView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.UserView
  # alias Inconn2ServiceWeb.PartyView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      username: user.username,
      password: user.password,
      party_id: user.party_id,
      role_id: user.role_id
    }
  end

  def render("showassoc.json", %{user: user}) do
    party = user.current_party
    IO.inspect(party)
    current_user = user.current_user
    IO.inspect(current_user)

    # %{data: render_one(party.get_field("current_party"), PartyView, "party.json")}
    %{data: render_one(current_user, UserView, "user.json")}
    IO.puts("object inside user view &&&&&&&&&&&&")
  end

  def render("error.json", %{error: error_message}) do
    %{errors: %{detail: [error_message]}}
  end
end
