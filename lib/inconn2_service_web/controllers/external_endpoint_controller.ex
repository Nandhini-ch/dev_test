defmodule Inconn2ServiceWeb.ExternalEndpointController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.ExternalEndpoints

  def info_from_token(conn, _) do
    bearer =  conn |> get_req_header("authorization")
    [_, token ] = bearer |> List.first() |> String.split(" ")
    claims = Inconn2Service.Guardian.Plug.current_claims(conn)
    claims["sub"] |> IO.inspect()
    data = ExternalEndpoints.get_resource_from_token(token)
    IO.inspect(data)
    render(conn, "token.json", data: data)
  end
end
