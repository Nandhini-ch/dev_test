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
end
