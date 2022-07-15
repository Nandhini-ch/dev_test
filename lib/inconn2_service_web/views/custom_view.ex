defmodule Inconn2ServiceWeb.CustomView do
  use Inconn2ServiceWeb, :view

  def render("fields.json", %{custom: fields}) do
    %{
      field_name: fields.field_name,
      field_label: fields.field_label,
      field_type: fields.field_type,
      field_placeholder: fields.field_placeholder
    }
  end
end
