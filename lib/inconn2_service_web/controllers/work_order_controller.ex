defmodule Inconn2ServiceWeb.WorkOrderController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkOrder

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    work_orders = Workorder.list_work_orders(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", work_orders: work_orders)
  end

  def index_for_user_by_qr(conn, %{"qr_string" => qr_string}) do
    work_orders = Workorder.list_work_orders_for_user_by_qr(qr_string, conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", work_orders: work_orders)
  end

  def work_order_premits_to_be_approved(conn, _) do
    work_orders = Workorder.get_work_order_premits_to_be_approved(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", work_orders: work_orders)
  end

  def work_orders_to_be_approved(conn, _) do
    work_orders = Workorder.get_work_orders_to_be_approved(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", work_orders: work_orders)
  end

  def work_orders_to_be_acknowledged(conn, _) do
    work_orders = Workorder.get_work_order_to_be_acknowledged(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", work_orders: work_orders)
  end

  def work_order_loto_to_be_checked(conn, _) do
    work_orders = Workorder.get_work_order_loto_to_be_checked(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", work_orders: work_orders)
  end

  def get_work_order_for_mobile(conn, _) do
    work_orders = Workorder.list_work_orders_mobile(conn.assigns.current_user, conn.assigns.sub_domain_prefix)
    render(conn, "mobile_index.json", work_orders: work_orders)
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

  def send_for_work_order_approval(conn, %{"id" => id}) do
    work_order = Workorder.get_work_order!(id, conn.assigns.sub_domain_prefix)
    with {:ok, %WorkOrder{} = work_order} <- Workorder.send_for_work_order_approval(work_order, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", work_order: work_order)
    end
  end

  def send_for_workpermit_approval(conn, %{"id" => id}) do
    work_order = Workorder.get_work_order!(id, conn.assigns.sub_domain_prefix)
    response = Workorder.send_for_workpermit_approval(work_order, conn.assigns.sub_domain_prefix, conn.assigns.current_user)
    case response.result do
      true ->
        render(conn, "permit_response.json", response: response)
      false ->
        conn
          |> put_status(:unprocessable_entity)
          |> put_view(Inconn2ServiceWeb.WorkOrderView)
          |> render("permit_response.json", response: response)
    end
  end

  def approve_work_permit(conn, %{"id" => id}) do
    with {:ok, %WorkOrder{} = work_order} <- Workorder.approve_work_permit(id, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", work_order: work_order)
    end
  end

  def approve_loto(conn, %{"id" => id}) do
    with {:ok, %WorkOrder{} = work_order} <- Workorder.approve_loto(id, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", work_order: work_order)
    end
  end


  def update_multiple(conn, %{"work_order_changes" => work_order_changes}) do
    work_orders = Workorder.update_work_orders(work_order_changes, conn.assigns.sub_domain_prefix, conn.assigns.current_user)
    render(conn, "index.json", work_orders: work_orders)
  end

  def delete(conn, %{"id" => id}) do
    work_order = Workorder.get_work_order!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkOrder{}} <- Workorder.delete_work_order(work_order, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

  def work_orders_of_user(conn, _params) do
    work_orders = Workorder.list_work_orders_of_user(conn.assigns.sub_domain_prefix, conn.assigns.current_user)
    render(conn, "index.json", work_orders: work_orders)
  end

  def update_asset_status(conn, %{"work_order_id" => work_order_id, "asset" => asset_params}) do
    work_order = Workorder.get_work_order!(work_order_id, conn.assigns.sub_domain_prefix)

    with {:ok, asset} <- Workorder.update_asset_status(work_order, asset_params, conn.assigns.sub_domain_prefix) do
      render(conn, "asset.json", asset: asset, asset_type: work_order.asset_type)
    end
  end
end
