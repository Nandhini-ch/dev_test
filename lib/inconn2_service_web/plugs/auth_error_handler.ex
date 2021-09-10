defmodule Inconn2ServiceWeb.Plugs.AuthErrorhandler do
  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    # body = Jason.encode!(%{message: to_string(type)})
    # send_resp(conn, 401, body)
    body = Jason.encode!(%{message: to_string(type)})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end
end
