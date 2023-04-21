defmodule Inconn2ServiceWeb.MessageTemplatesController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Communication
  alias Inconn2Service.Communication.MessageTemplates

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    message_templates = Communication.list_message_templates()
    render(conn, "index.json", message_templates: message_templates)
  end

  def create(conn, %{"message_templates" => message_templates_params}) do
    with {:ok, %MessageTemplates{} = message_templates} <- Communication.create_message_templates(message_templates_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.message_templates_path(conn, :show, message_templates))
      |> render("show.json", message_templates: message_templates)
    end
  end

  def show(conn, %{"id" => id}) do
    message_templates = Communication.get_message_templates!(id)
    render(conn, "show.json", message_templates: message_templates)
  end

  def update(conn, %{"id" => id, "message_templates" => message_templates_params}) do
    message_templates = Communication.get_message_templates!(id)

    with {:ok, %MessageTemplates{} = message_templates} <- Communication.update_message_templates(message_templates, message_templates_params) do
      render(conn, "show.json", message_templates: message_templates)
    end
  end

  def delete(conn, %{"id" => id}) do
    message_templates = Communication.get_message_templates!(id)

    with {:ok, %MessageTemplates{}} <- Communication.delete_message_templates(message_templates) do
      send_resp(conn, :no_content, "")
    end
  end
end
