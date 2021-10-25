defmodule Inconn2ServiceWeb.CheckController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.CheckListConfig
  alias Inconn2Service.CheckListConfig.Check

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    checks = CheckListConfig.list_checks(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", checks: checks)
  end

  def create(conn, %{"check" => check_params}) do
    with {:ok, %Check{} = check} <- CheckListConfig.create_check(check_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.check_path(conn, :show, check))
      |> render("show.json", check: check)
    end
  end

  def show(conn, %{"id" => id}) do
    check = CheckListConfig.get_check!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", check: check)
  end

  def update(conn, %{"id" => id, "check" => check_params}) do
    check = CheckListConfig.get_check!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Check{} = check} <- CheckListConfig.update_check(check, check_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", check: check)
    end
  end

  def delete(conn, %{"id" => id}) do
    check = CheckListConfig.get_check!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Check{}} <- CheckListConfig.delete_check(check, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

  def activate_check(conn, %{"id" => id}) do
    check = CheckListConfig.get_check!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Check{} = check} <- CheckListConfig.update_check_active_status(check, %{"active" => true}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", check: check)
    end
  end

  def deactivate_check(conn, %{"id" => id}) do
    check = CheckListConfig.get_check!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Check{} = check} <- CheckListConfig.update_check_active_status(check, %{"active" => false}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", check: check)
    end
  end
end
