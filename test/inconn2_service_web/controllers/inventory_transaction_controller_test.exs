defmodule Inconn2ServiceWeb.InventoryTransactionControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.InventoryTransaction

  @create_attrs %{
    inventory_location_id: 42,
    item_id: 42,
    price: 120.5,
    quantity: 120.5,
    reference: "some reference",
    supplier_id: 42,
    transaction_type: "some transaction_type",
    uom_id: 42,
    workorder_id: 42
  }
  @update_attrs %{
    inventory_location_id: 43,
    item_id: 43,
    price: 456.7,
    quantity: 456.7,
    reference: "some updated reference",
    supplier_id: 43,
    transaction_type: "some updated transaction_type",
    uom_id: 43,
    workorder_id: 43
  }
  @invalid_attrs %{inventory_location_id: nil, item_id: nil, price: nil, quantity: nil, reference: nil, supplier_id: nil, transaction_type: nil, uom_id: nil, workorder_id: nil}

  def fixture(:inventory_transaction) do
    {:ok, inventory_transaction} = Inventory.create_inventory_transaction(@create_attrs)
    inventory_transaction
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all inventory_transactions", %{conn: conn} do
      conn = get(conn, Routes.inventory_transaction_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create inventory_transaction" do
    test "renders inventory_transaction when data is valid", %{conn: conn} do
      conn = post(conn, Routes.inventory_transaction_path(conn, :create), inventory_transaction: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.inventory_transaction_path(conn, :show, id))

      assert %{
               "id" => id,
               "inventory_location_id" => 42,
               "item_id" => 42,
               "price" => 120.5,
               "quantity" => 120.5,
               "reference" => "some reference",
               "supplier_id" => 42,
               "transaction_type" => "some transaction_type",
               "uom_id" => 42,
               "workorder_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.inventory_transaction_path(conn, :create), inventory_transaction: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update inventory_transaction" do
    setup [:create_inventory_transaction]

    test "renders inventory_transaction when data is valid", %{conn: conn, inventory_transaction: %InventoryTransaction{id: id} = inventory_transaction} do
      conn = put(conn, Routes.inventory_transaction_path(conn, :update, inventory_transaction), inventory_transaction: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.inventory_transaction_path(conn, :show, id))

      assert %{
               "id" => id,
               "inventory_location_id" => 43,
               "item_id" => 43,
               "price" => 456.7,
               "quantity" => 456.7,
               "reference" => "some updated reference",
               "supplier_id" => 43,
               "transaction_type" => "some updated transaction_type",
               "uom_id" => 43,
               "workorder_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, inventory_transaction: inventory_transaction} do
      conn = put(conn, Routes.inventory_transaction_path(conn, :update, inventory_transaction), inventory_transaction: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete inventory_transaction" do
    setup [:create_inventory_transaction]

    test "deletes chosen inventory_transaction", %{conn: conn, inventory_transaction: inventory_transaction} do
      conn = delete(conn, Routes.inventory_transaction_path(conn, :delete, inventory_transaction))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.inventory_transaction_path(conn, :show, inventory_transaction))
      end
    end
  end

  defp create_inventory_transaction(_) do
    inventory_transaction = fixture(:inventory_transaction)
    %{inventory_transaction: inventory_transaction}
  end
end
