defmodule Inconn2ServiceWeb.InventorySupplierItemControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.InventorySupplierItem

  @create_attrs %{

  }
  @update_attrs %{

  }
  @invalid_attrs %{}

  def fixture(:inventory_supplier_item) do
    {:ok, inventory_supplier_item} = InventoryManagement.create_inventory_supplier_item(@create_attrs)
    inventory_supplier_item
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all inventory_supplier_items", %{conn: conn} do
      conn = get(conn, Routes.inventory_supplier_item_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create inventory_supplier_item" do
    test "renders inventory_supplier_item when data is valid", %{conn: conn} do
      conn = post(conn, Routes.inventory_supplier_item_path(conn, :create), inventory_supplier_item: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.inventory_supplier_item_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.inventory_supplier_item_path(conn, :create), inventory_supplier_item: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update inventory_supplier_item" do
    setup [:create_inventory_supplier_item]

    test "renders inventory_supplier_item when data is valid", %{conn: conn, inventory_supplier_item: %InventorySupplierItem{id: id} = inventory_supplier_item} do
      conn = put(conn, Routes.inventory_supplier_item_path(conn, :update, inventory_supplier_item), inventory_supplier_item: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.inventory_supplier_item_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, inventory_supplier_item: inventory_supplier_item} do
      conn = put(conn, Routes.inventory_supplier_item_path(conn, :update, inventory_supplier_item), inventory_supplier_item: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete inventory_supplier_item" do
    setup [:create_inventory_supplier_item]

    test "deletes chosen inventory_supplier_item", %{conn: conn, inventory_supplier_item: inventory_supplier_item} do
      conn = delete(conn, Routes.inventory_supplier_item_path(conn, :delete, inventory_supplier_item))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.inventory_supplier_item_path(conn, :show, inventory_supplier_item))
      end
    end
  end

  defp create_inventory_supplier_item(_) do
    inventory_supplier_item = fixture(:inventory_supplier_item)
    %{inventory_supplier_item: inventory_supplier_item}
  end
end
