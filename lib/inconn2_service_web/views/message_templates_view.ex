defmodule Inconn2ServiceWeb.MessageTemplatesView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.MessageTemplatesView

  def render("index.json", %{message_templates: message_templates}) do
    %{data: render_many(message_templates, MessageTemplatesView, "message_templates.json")}
  end

  def render("show.json", %{message_templates: message_templates}) do
    %{data: render_one(message_templates, MessageTemplatesView, "message_templates.json")}
  end

  def render("message_templates.json", %{message_templates: message_templates}) do
    %{id: message_templates.id,
      message: message_templates.message,
      template_name: message_templates.template_name,
      dlt_template_id: message_templates.dlt_template_id,
      telemarketer_id: message_templates.telemarketer_id,
      code: message_templates.code
    }
  end
end
