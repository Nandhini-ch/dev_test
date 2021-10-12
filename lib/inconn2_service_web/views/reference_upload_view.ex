defmodule Inconn2ServiceWeb.ReferenceUploadView do
  use Inconn2ServiceWeb, :view

  def render("success.json", %{}) do
    %{"status" => "Uploaded successfully"}
  end

  def render("failure.json", %{failed_data: error_data}) do
    %{"status" => error_data}
  end

  def render("invalid.json", %{}) do
    %{"status" => "Invalid CSV"}
  end
end
