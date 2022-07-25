defmodule Inconn2ServiceWeb.CheckListController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.CheckListConfig
  alias Inconn2Service.CheckListConfig.CheckList

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    check_lists = CheckListConfig.list_check_lists(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", check_lists: check_lists)
  end

  def create(conn, %{"check_list" => check_list_params}) do
    with {:ok, %CheckList{} = check_list} <- CheckListConfig.create_check_list(check_list_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.check_list_path(conn, :show, check_list))
      |> render("show.json", check_list: check_list)
    end
  end

  def show(conn, %{"id" => id}) do
    check_list = CheckListConfig.get_check_list!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", check_list: check_list)
  end

  def update(conn, %{"id" => id, "check_list" => check_list_params}) do
    check_list = CheckListConfig.get_check_list!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %CheckList{} = check_list} <- CheckListConfig.update_check_list(check_list, check_list_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", check_list: check_list)
    end
  end

  def delete(conn, %{"id" => id}) do
    check_list = CheckListConfig.get_check_list!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %CheckList{}} <- CheckListConfig.delete_check_list(check_list, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
