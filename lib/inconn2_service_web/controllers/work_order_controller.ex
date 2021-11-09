defmodule Inconn2ServiceWeb.WorkOrderController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkOrder

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    work_orders = Workorder.list_work_orders(conn.assigns.sub_domain_prefix)
    work_orders = Enum.map(work_orders, fn work_order -> get_work_order_with_asset(work_order, conn.assigns.sub_domain_prefix) end)
    render(conn, "index.json", work_orders: work_orders)
  end

  def create(conn, %{"work_order" => work_order_params}) do
    with {:ok, %WorkOrder{} = work_order} <- Workorder.create_work_order(work_order_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      work_order = get_work_order_with_asset(work_order, conn.assigns.sub_domain_prefix)
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.work_order_path(conn, :show, work_order))
      |> render("show.json", work_order: work_order)
    end
  end

  def show(conn, %{"id" => id}) do
    work_order = Workorder.get_work_order!(id, conn.assigns.sub_domain_prefix)
    work_order = get_work_order_with_asset(work_order, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", work_order: work_order)
  end

  def update(conn, %{"id" => id, "work_order" => work_order_params}) do
    work_order = Workorder.get_work_order!(id, conn.assigns.sub_domain_prefix)
    work_order = get_work_order_with_asset(work_order, conn.assigns.sub_domain_prefix)
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

  def work_orders_of_user(conn, _params) do
    work_orders = Workorder.list_work_orders_of_user(conn.assigns.sub_domain_prefix, conn.assigns.current_user)
    work_orders = Enum.map(work_orders, fn work_order -> get_work_order_with_asset(work_order, conn.assigns.sub_domain_prefix) end)
    render(conn, "index.json", work_orders: work_orders)
  end

  defp get_work_order_with_asset(work_order, prefix) do
    workorder_template_id = work_order.workorder_template_id
    asset_id = work_order.asset_id
    workorder_template = Workorder.get_workorder_template(workorder_template_id, prefix)
    if workorder_template != nil and asset_id != nil do
      asset_category = AssetConfig.get_asset_category(workorder_template.asset_category_id, prefix)
      asset_type = asset_category.asset_type
      case asset_type do
        "L" ->
          location = AssetConfig.get_location(asset_id, prefix)
          Map.put_new(work_order, :asset_type, "L") |> Map.put_new(:asset_name, location.name)
        "E" ->
          equipment = AssetConfig.get_equipment(asset_id, prefix)
          Map.put_new(work_order, :asset_type, "E") |> Map.put_new(:asset_name, equipment.name)
      end
    else
      Map.put_new(work_order, :asset_type, nil) |> Map.put_new(:asset_name, nil)
    end
  end
end
