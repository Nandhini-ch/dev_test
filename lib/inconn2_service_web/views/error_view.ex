defmodule Inconn2ServiceWeb.ErrorView do
  use Inconn2ServiceWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal Server Error"}}
  end

  def render("401.json", _assigns) do
    %{errors: %{detail: "Error in operations"}}
  end

  def render("error_delete.json", %{msg: msg}) do
    %{errors: %{detail: msg}}
  end

  def render("error_create.json", %{msg: msg}) do
    %{errors: %{detail: msg}}
  end

  def render("error.json", %{msg: msg}) do
    %{errors: %{detail: msg}}
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
