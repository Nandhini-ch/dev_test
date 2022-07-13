defmodule Inconn2ServiceWeb.CheckTypeController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.CheckListConfig
  alias Inconn2Service.CheckListConfig.CheckType

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    check_types = CheckListConfig.list_check_types(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", check_types: check_types)
  end

  def create(conn, %{"check_type" => check_type_params}) do
    with {:ok, %CheckType{} = check_type} <- CheckListConfig.create_check_type(check_type_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.check_type_path(conn, :show, check_type))
      |> render("show.json", check_type: check_type)
    end
  end

  def show(conn, %{"id" => id}) do
    check_type = CheckListConfig.get_check_type!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", check_type: check_type)
  end

  def update(conn, %{"id" => id, "check_type" => check_type_params}) do
    check_type = CheckListConfig.get_check_type!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %CheckType{} = check_type} <- CheckListConfig.update_check_type(check_type, check_type_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", check_type: check_type)
    end
  end

  def delete(conn, %{"id" => id}) do
    check_type = CheckListConfig.get_check_type!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %CheckType{}} <- CheckListConfig.delete_check_type(check_type, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
