defmodule Inconn2ServiceWeb.WidgetView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.WidgetView

  def render("index.json", %{widgets: widgets}) do
    %{data: render_many(widgets, WidgetView, "widget.json")}
  end

  def render("show.json", %{widget: widget}) do
    %{data: render_one(widget, WidgetView, "widget.json")}
  end

  def render("widget.json", %{widget: widget}) do
    %{id: widget.id,
      code: widget.code,
      description: widget.description,
      title: widget.title}
  end
end
