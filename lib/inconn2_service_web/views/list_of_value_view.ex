defmodule Inconn2ServiceWeb.ListOfValueView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.ListOfValueView

  def render("index.json", %{list_of_values: list_of_values}) do
    %{data: render_many(list_of_values, ListOfValueView, "list_of_value.json")}
  end

  def render("show.json", %{list_of_value: list_of_value}) do
    %{data: render_one(list_of_value, ListOfValueView, "list_of_value.json")}
  end

  def render("list_of_value.json", %{list_of_value: list_of_value}) do
    %{id: list_of_value.id,
      name: list_of_value.name,
      values: list_of_value.values}
  end
end
