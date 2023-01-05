defmodule Inconn2ServiceWeb.ExternalEndpointView do
  use Inconn2ServiceWeb, :view

  def render("token.json", %{data: data}) do
    %{data: data}
  end
end
