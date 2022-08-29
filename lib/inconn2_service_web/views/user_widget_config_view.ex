defmodule Inconn2ServiceWeb.UserWidgetConfigView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.UserWidgetConfigView

  def render("index.json", %{user_widget_configs: user_widget_configs}) do
    %{data: render_many(user_widget_configs, UserWidgetConfigView, "user_widget_config.json")}
  end

  def render("show.json", %{user_widget_config: user_widget_config}) do
    %{data: render_one(user_widget_config, UserWidgetConfigView, "user_widget_config.json")}
  end

  def render("user_widget_config.json", %{user_widget_config: user_widget_config}) do
    %{id: user_widget_config.id,
      widget_code: user_widget_config.widget_code,
      position: user_widget_config.position,
      user_id: user_widget_config.user_id}
  end
end
