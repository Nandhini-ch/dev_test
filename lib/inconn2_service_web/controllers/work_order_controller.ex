defmodule Inconn2ServiceWeb.WorkOrderController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkOrder

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    work_orders = Workorder.list_work_orders(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", work_orders: work_orders)
  end

  def create(conn, %{"work_order" => work_order_params}) do
    with {:ok, %WorkOrder{} = work_order} <- Workorder.create_work_order(work_order_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.work_order_path(conn, :show, work_order))
      |> render("show.json", work_order: work_order)
    end
  end

  def show(conn, %{"id" => id}) do
    work_order = Workorder.get_work_order!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", work_order: work_order)
  end

  def update(conn, %{"id" => id, "work_order" => work_order_params}) do
    work_order = Workorder.get_work_order!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkOrder{} = work_order} <- Workorder.update_work_order(work_order, work_order_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", work_order: work_order)
    end
  end

  def delete(conn, %{"id" => id}) do
    work_order = Workorder.get_work_order!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkOrder{}} <- Workorder.delete_work_order(work_order, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

  def work_permitted(conn, %{"id" => id}) do
    work_order = Workorder.get_work_order!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkOrder{} = work_order} <- Workorder.status_work_permitted(work_order, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", work_order: work_order)
    end
  end

  def loto_locked(conn, %{"id" => id}) do
    work_order = Workorder.get_work_order!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkOrder{} = work_order} <- Workorder.status_loto_locked(work_order, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", work_order: work_order)
    end
  end

  def in_progress(conn, %{"id" => id}) do
    work_order = Workorder.get_work_order!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkOrder{} = work_order} <- Workorder.status_in_progress(work_order, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", work_order: work_order)
    end
  end

  def completed(conn, %{"id" => id}) do
    work_order = Workorder.get_work_order!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkOrder{} = work_order} <- Workorder.status_completed(work_order, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", work_order: work_order)
    end
  end

  def loto_released(conn, %{"id" => id}) do
    work_order = Workorder.get_work_order!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkOrder{} = work_order} <- Workorder.status_loto_released(work_order, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", work_order: work_order)
    end
  end

  def cancelled(conn, %{"id" => id}) do
    work_order = Workorder.get_work_order!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkOrder{} = work_order} <- Workorder.status_cancelled(work_order, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", work_order: work_order)
    end
  end

  def hold(conn, %{"id" => id}) do
    work_order = Workorder.get_work_order!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkOrder{} = work_order} <- Workorder.status_hold(work_order, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", work_order: work_order)
    end
  end

end
