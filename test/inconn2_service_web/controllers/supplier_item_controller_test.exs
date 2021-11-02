defmodule Inconn2ServiceWeb.SupplierItemControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.SupplierItem

  @create_attrs %{
    item_id: 42,
    price: 120.5,
    price_unit_uom_id: 42,
    supplier_id: 42,
    supplier_part_no: "some supplier_part_no"
  }
  @update_attrs %{
    item_id: 43,
    price: 456.7,
    price_unit_uom_id: 43,
    supplier_id: 43,
    supplier_part_no: "some updated supplier_part_no"
  }
  @invalid_attrs %{item_id: nil, price: nil, price_unit_uom_id: nil, supplier_id: nil, supplier_part_no: nil}

  def fixture(:supplier_item) do
    {:ok, supplier_item} = Inventory.create_supplier_item(@create_attrs)
    supplier_item
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all supplier_items", %{conn: conn} do
      conn = get(conn, Routes.supplier_item_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create supplier_item" do
    test "renders supplier_item when data is valid", %{conn: conn} do
      conn = post(conn, Routes.supplier_item_path(conn, :create), supplier_item: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.supplier_item_path(conn, :show, id))

      assert %{
               "id" => id,
               "item_id" => 42,
               "price" => 120.5,
               "price_unit_uom_id" => 42,
               "supplier_id" => 42,
               "supplier_part_no" => "some supplier_part_no"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.supplier_item_path(conn, :create), supplier_item: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update supplier_item" do
    setup [:create_supplier_item]

    test "renders supplier_item when data is valid", %{conn: conn, supplier_item: %SupplierItem{id: id} = supplier_item} do
      conn = put(conn, Routes.supplier_item_path(conn, :update, supplier_item), supplier_item: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.supplier_item_path(conn, :show, id))

      assert %{
               "id" => id,
               "item_id" => 43,
               "price" => 456.7,
               "price_unit_uom_id" => 43,
               "supplier_id" => 43,
               "supplier_part_no" => "some updated supplier_part_no"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, supplier_item: supplier_item} do
      conn = put(conn, Routes.supplier_item_path(conn, :update, supplier_item), supplier_item: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete supplier_item" do
    setup [:create_supplier_item]

    test "deletes chosen supplier_item", %{conn: conn, supplier_item: supplier_item} do
      conn = delete(conn, Routes.supplier_item_path(conn, :delete, supplier_item))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.supplier_item_path(conn, :show, supplier_item))
      end
    end
  end

  defp create_supplier_item(_) do
    supplier_item = fixture(:supplier_item)
    %{supplier_item: supplier_item}
  end
end
