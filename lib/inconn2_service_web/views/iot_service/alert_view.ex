defmodule Inconn2ServiceWeb.IotService.AlertView do
  use Inconn2ServiceWeb, :view

  def render("alert.json", %{data: data}) do
    %{data: data}
  end
end
