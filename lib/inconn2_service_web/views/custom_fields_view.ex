defmodule Inconn2ServiceWeb.CustomFieldsView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{CustomView, CustomFieldsView}

  def render("index.json", %{custom_fields: custom_fields}) do
    %{data: render_many(custom_fields, CustomFieldsView, "custom_fields.json")}
  end

  def render("show.json", %{custom_fields: custom_fields}) do
    %{data: render_one(custom_fields, CustomFieldsView, "custom_fields.json")}
  end

  def render("custom_fields.json", %{custom_fields: custom_fields}) do
    %{
        id: custom_fields.id,
        entity: custom_fields.entity,
        fields: render_many(custom_fields.fields, CustomView, "fields.json")
        # fields: custom_fields.fields
      }
  end
end
