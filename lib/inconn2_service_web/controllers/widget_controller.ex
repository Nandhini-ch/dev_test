defmodule Inconn2ServiceWeb.WidgetController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Common
  alias Inconn2Service.Common.Widget

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    widgets = Common.list_widgets()
    render(conn, "index.json", widgets: widgets)
  end

  def create(conn, %{"widget" => widget_params}) do
    with {:ok, widgets} <- Common.create_widgets(widget_params) do
      conn
      |> put_status(:created)
      |> render("index.json", widgets: widgets)
    end
  end

  def show(conn, %{"id" => id}) do
    widget = Common.get_widget!(id)
    render(conn, "show.json", widget: widget)
  end

  def update(conn, %{"id" => id, "widget" => widget_params}) do
    widget = Common.get_widget!(id)

    with {:ok, %Widget{} = widget} <- Common.update_widget(widget, widget_params) do
      render(conn, "show.json", widget: widget)
    end
  end

  def delete(conn, %{"id" => id}) do
    widget = Common.get_widget!(id)

    with {:ok, %Widget{}} <- Common.delete_widget(widget) do
      send_resp(conn, :no_content, "")
    end
  end
end
