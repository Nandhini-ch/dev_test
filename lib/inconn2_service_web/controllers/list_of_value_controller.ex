defmodule Inconn2ServiceWeb.ListOfValueController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Common
  alias Inconn2Service.Common.ListOfValue

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    list_of_values = Common.list_list_of_values(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", list_of_values: list_of_values)
  end

  def create(conn, %{"list_of_value" => list_of_value_params}) do
    with {:ok, %ListOfValue{} = list_of_value} <- Common.create_list_of_value(list_of_value_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.list_of_value_path(conn, :show, list_of_value))
      |> render("show.json", list_of_value: list_of_value)
    end
  end

  def show(conn, %{"id" => id}) do
    list_of_value = Common.get_list_of_value!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", list_of_value: list_of_value)
  end

  def update(conn, %{"id" => id, "list_of_value" => list_of_value_params}) do
    list_of_value = Common.get_list_of_value!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %ListOfValue{} = list_of_value} <- Common.update_list_of_value(list_of_value, list_of_value_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", list_of_value: list_of_value)
    end
  end

  def delete(conn, %{"id" => id}) do
    list_of_value = Common.get_list_of_value!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %ListOfValue{}} <- Common.delete_list_of_value(list_of_value, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
