defmodule Inconn2ServiceWeb.DataUploadView do
  use Inconn2ServiceWeb, :view

  def render("success.json", %{}) do
    %{"status" => "Uploaded successfully"}
  end
end
