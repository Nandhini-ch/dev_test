defmodule Inconn2ServiceWeb.Plugs.AssignUser do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    case Guardian.Plug.current_resource(conn) do
      nil -> assign(conn, :current_user, nil)
      user -> assign(conn, :current_user, user)
    end
  end
end
