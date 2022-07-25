defmodule Inconn2ServiceWeb.CustomFieldsController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Custom
  alias Inconn2Service.Custom.CustomFields

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    custom_fields = Custom.list_custom_fields(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", custom_fields: custom_fields)
  end

  def create(conn, %{"custom_fields" => custom_fields_params}) do
    with {:ok, %CustomFields{} = custom_fields} <- Custom.create_custom_fields(custom_fields_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.custom_fields_path(conn, :show, custom_fields))
      |> render("show.json", custom_fields: custom_fields)
    end
  end

  def show(conn, %{"id" => id}) do
    custom_fields = Custom.get_custom_fields!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", custom_fields: custom_fields)
  end

  def update(conn, %{"id" => id, "custom_fields" => custom_fields_params}) do
    custom_fields = Custom.get_custom_fields!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %CustomFields{} = custom_fields} <- Custom.update_custom_fields(custom_fields, custom_fields_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", custom_fields: custom_fields)
    end
  end

  def delete(conn, %{"id" => id}) do
    custom_fields = Custom.get_custom_fields!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %CustomFields{}} <- Custom.delete_custom_fields(custom_fields, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
