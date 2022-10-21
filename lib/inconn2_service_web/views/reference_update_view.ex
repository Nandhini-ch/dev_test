defmodule Inconn2ServiceWeb.ReferenceUpdateView do
  use Inconn2ServiceWeb, :view

  def render("message.json", _) do
    %{
      success: true
    }
  end

end
