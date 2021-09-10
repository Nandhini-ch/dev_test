defmodule Inconn2ServiceWeb.SessionView do
  use Inconn2ServiceWeb, :view

  def render("success.json", %{token: token}) do
    %{result: "success", token: token}
  end

  def render("failure.json", %{error: params}) do
    %{result: params}
  end
end
