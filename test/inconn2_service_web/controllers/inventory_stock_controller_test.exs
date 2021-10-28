defmodule Inconn2ServiceWeb.InventoryStockControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.InventoryStock

  @create_attrs %{
    inventory_location_id: 42,
    item_id: 42,
    quantity: 120.5
  }
  @update_attrs %{
    inventory_location_id: 43,
    item_id: 43,
    quantity: 456.7
  }
  @invalid_attrs %{inventory_location_id: nil, item_id: nil, quantity: nil}

  def fixture(:inventory_stock) do
    {:ok, inventory_stock} = Inventory.create_inventory_stock(@create_attrs)
    inventory_stock
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all inventory_stocks", %{conn: conn} do
      conn = get(conn, Routes.inventory_stock_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create inventory_stock" do
    test "renders inventory_stock when data is valid", %{conn: conn} do
      conn = post(conn, Routes.inventory_stock_path(conn, :create), inventory_stock: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.inventory_stock_path(conn, :show, id))

      assert %{
               "id" => id,
               "inventory_location_id" => 42,
               "item_id" => 42,
               "quantity" => 120.5
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.inventory_stock_path(conn, :create), inventory_stock: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update inventory_stock" do
    setup [:create_inventory_stock]

    test "renders inventory_stock when data is valid", %{conn: conn, inventory_stock: %InventoryStock{id: id} = inventory_stock} do
      conn = put(conn, Routes.inventory_stock_path(conn, :update, inventory_stock), inventory_stock: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.inventory_stock_path(conn, :show, id))

      assert %{
               "id" => id,
               "inventory_location_id" => 43,
               "item_id" => 43,
               "quantity" => 456.7
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, inventory_stock: inventory_stock} do
      conn = put(conn, Routes.inventory_stock_path(conn, :update, inventory_stock), inventory_stock: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete inventory_stock" do
    setup [:create_inventory_stock]

    test "deletes chosen inventory_stock", %{conn: conn, inventory_stock: inventory_stock} do
      conn = delete(conn, Routes.inventory_stock_path(conn, :delete, inventory_stock))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.inventory_stock_path(conn, :show, inventory_stock))
      end
    end
  end

  defp create_inventory_stock(_) do
    inventory_stock = fixture(:inventory_stock)
    %{inventory_stock: inventory_stock}
  end
end
