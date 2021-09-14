defmodule Inconn2ServiceWeb.WorkOrderControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkOrder

  @create_attrs %{
    asset_id: 42,
    site_id: 42,
    type: "some type"
  }
  @update_attrs %{
    asset_id: 43,
    site_id: 43,
    type: "some updated type"
  }
  @invalid_attrs %{asset_id: nil, site_id: nil, type: nil}

  def fixture(:work_order) do
    {:ok, work_order} = Workorder.create_work_order(@create_attrs)
    work_order
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all work_orders", %{conn: conn} do
      conn = get(conn, Routes.work_order_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create work_order" do
    test "renders work_order when data is valid", %{conn: conn} do
      conn = post(conn, Routes.work_order_path(conn, :create), work_order: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.work_order_path(conn, :show, id))

      assert %{
               "id" => id,
               "asset_id" => 42,
               "site_id" => 42,
               "type" => "some type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.work_order_path(conn, :create), work_order: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update work_order" do
    setup [:create_work_order]

    test "renders work_order when data is valid", %{conn: conn, work_order: %WorkOrder{id: id} = work_order} do
      conn = put(conn, Routes.work_order_path(conn, :update, work_order), work_order: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.work_order_path(conn, :show, id))

      assert %{
               "id" => id,
               "asset_id" => 43,
               "site_id" => 43,
               "type" => "some updated type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, work_order: work_order} do
      conn = put(conn, Routes.work_order_path(conn, :update, work_order), work_order: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete work_order" do
    setup [:create_work_order]

    test "deletes chosen work_order", %{conn: conn, work_order: work_order} do
      conn = delete(conn, Routes.work_order_path(conn, :delete, work_order))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.work_order_path(conn, :show, work_order))
      end
    end
  end

  defp create_work_order(_) do
    work_order = fixture(:work_order)
    %{work_order: work_order}
  end
end
