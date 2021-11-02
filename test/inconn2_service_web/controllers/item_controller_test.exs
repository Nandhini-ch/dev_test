defmodule Inconn2ServiceWeb.ItemControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.Item

  @create_attrs %{
    asset_categories_ids: [],
    consume_unit: "some consume_unit",
    inventory_unit_id: "some inventory_unit_id",
    min_order_quantity: 120.5,
    name: "some name",
    part_no: "some part_no",
    purchase_unit_id: "some purchase_unit_id",
    reorder_quantity: 120.5,
    type: "some type"
  }
  @update_attrs %{
    asset_categories_ids: [],
    consume_unit: "some updated consume_unit",
    inventory_unit_id: "some updated inventory_unit_id",
    min_order_quantity: 456.7,
    name: "some updated name",
    part_no: "some updated part_no",
    purchase_unit_id: "some updated purchase_unit_id",
    reorder_quantity: 456.7,
    type: "some updated type"
  }
  @invalid_attrs %{asset_categories_ids: nil, consume_unit: nil, inventory_unit_id: nil, min_order_quantity: nil, name: nil, part_no: nil, purchase_unit_id: nil, reorder_quantity: nil, type: nil}

  def fixture(:item) do
    {:ok, item} = Inventory.create_item(@create_attrs)
    item
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all items", %{conn: conn} do
      conn = get(conn, Routes.item_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create item" do
    test "renders item when data is valid", %{conn: conn} do
      conn = post(conn, Routes.item_path(conn, :create), item: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.item_path(conn, :show, id))

      assert %{
               "id" => id,
               "asset_categories_ids" => [],
               "consume_unit" => "some consume_unit",
               "inventory_unit_id" => "some inventory_unit_id",
               "min_order_quantity" => 120.5,
               "name" => "some name",
               "part_no" => "some part_no",
               "purchase_unit_id" => "some purchase_unit_id",
               "reorder_quantity" => 120.5,
               "type" => "some type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.item_path(conn, :create), item: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update item" do
    setup [:create_item]

    test "renders item when data is valid", %{conn: conn, item: %Item{id: id} = item} do
      conn = put(conn, Routes.item_path(conn, :update, item), item: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.item_path(conn, :show, id))

      assert %{
               "id" => id,
               "asset_categories_ids" => [],
               "consume_unit" => "some updated consume_unit",
               "inventory_unit_id" => "some updated inventory_unit_id",
               "min_order_quantity" => 456.7,
               "name" => "some updated name",
               "part_no" => "some updated part_no",
               "purchase_unit_id" => "some updated purchase_unit_id",
               "reorder_quantity" => 456.7,
               "type" => "some updated type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, item: item} do
      conn = put(conn, Routes.item_path(conn, :update, item), item: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete item" do
    setup [:create_item]

    test "deletes chosen item", %{conn: conn, item: item} do
      conn = delete(conn, Routes.item_path(conn, :delete, item))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.item_path(conn, :show, item))
      end
    end
  end

  defp create_item(_) do
    item = fixture(:item)
    %{item: item}
  end
end
