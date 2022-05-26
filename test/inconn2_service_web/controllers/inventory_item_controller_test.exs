defmodule Inconn2ServiceWeb.InventoryItemControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.InventoryItem

  @create_attrs %{
    approval_user_id: 42,
    asset_category_ids: [],
    attachment: "some attachment",
    is_approval_required: true,
    iten_type: "some iten_type",
    minumum_stock_level: 42,
    name: "some name",
    part_no: "some part_no",
    remarks: "some remarks",
    unit_price: 120.5,
    uom_category_id: 42
  }
  @update_attrs %{
    approval_user_id: 43,
    asset_category_ids: [],
    attachment: "some updated attachment",
    is_approval_required: false,
    iten_type: "some updated iten_type",
    minumum_stock_level: 43,
    name: "some updated name",
    part_no: "some updated part_no",
    remarks: "some updated remarks",
    unit_price: 456.7,
    uom_category_id: 43
  }
  @invalid_attrs %{approval_user_id: nil, asset_category_ids: nil, attachment: nil, is_approval_required: nil, iten_type: nil, minumum_stock_level: nil, name: nil, part_no: nil, remarks: nil, unit_price: nil, uom_category_id: nil}

  def fixture(:inventory_item) do
    {:ok, inventory_item} = InventoryManagement.create_inventory_item(@create_attrs)
    inventory_item
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all inventory_items", %{conn: conn} do
      conn = get(conn, Routes.inventory_item_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create inventory_item" do
    test "renders inventory_item when data is valid", %{conn: conn} do
      conn = post(conn, Routes.inventory_item_path(conn, :create), inventory_item: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.inventory_item_path(conn, :show, id))

      assert %{
               "id" => id,
               "approval_user_id" => 42,
               "asset_category_ids" => [],
               "attachment" => "some attachment",
               "is_approval_required" => true,
               "iten_type" => "some iten_type",
               "minumum_stock_level" => 42,
               "name" => "some name",
               "part_no" => "some part_no",
               "remarks" => "some remarks",
               "unit_price" => 120.5,
               "uom_category_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.inventory_item_path(conn, :create), inventory_item: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update inventory_item" do
    setup [:create_inventory_item]

    test "renders inventory_item when data is valid", %{conn: conn, inventory_item: %InventoryItem{id: id} = inventory_item} do
      conn = put(conn, Routes.inventory_item_path(conn, :update, inventory_item), inventory_item: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.inventory_item_path(conn, :show, id))

      assert %{
               "id" => id,
               "approval_user_id" => 43,
               "asset_category_ids" => [],
               "attachment" => "some updated attachment",
               "is_approval_required" => false,
               "iten_type" => "some updated iten_type",
               "minumum_stock_level" => 43,
               "name" => "some updated name",
               "part_no" => "some updated part_no",
               "remarks" => "some updated remarks",
               "unit_price" => 456.7,
               "uom_category_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, inventory_item: inventory_item} do
      conn = put(conn, Routes.inventory_item_path(conn, :update, inventory_item), inventory_item: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete inventory_item" do
    setup [:create_inventory_item]

    test "deletes chosen inventory_item", %{conn: conn, inventory_item: inventory_item} do
      conn = delete(conn, Routes.inventory_item_path(conn, :delete, inventory_item))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.inventory_item_path(conn, :show, inventory_item))
      end
    end
  end

  defp create_inventory_item(_) do
    inventory_item = fixture(:inventory_item)
    %{inventory_item: inventory_item}
  end
end
