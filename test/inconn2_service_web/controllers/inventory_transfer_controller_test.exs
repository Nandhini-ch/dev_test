defmodule Inconn2ServiceWeb.InventoryTransferControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.InventoryTransfer

  @create_attrs %{
    from_location_id: 42,
    quantity: 42,
    reference: "some reference",
    to_location_id: 42,
    uom_id: 42
  }
  @update_attrs %{
    from_location_id: 43,
    quantity: 43,
    reference: "some updated reference",
    to_location_id: 43,
    uom_id: 43
  }
  @invalid_attrs %{from_location_id: nil, quantity: nil, reference: nil, to_location_id: nil, uom_id: nil}

  def fixture(:inventory_transfer) do
    {:ok, inventory_transfer} = Inventory.create_inventory_transfer(@create_attrs)
    inventory_transfer
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all inventory_transfers", %{conn: conn} do
      conn = get(conn, Routes.inventory_transfer_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create inventory_transfer" do
    test "renders inventory_transfer when data is valid", %{conn: conn} do
      conn = post(conn, Routes.inventory_transfer_path(conn, :create), inventory_transfer: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.inventory_transfer_path(conn, :show, id))

      assert %{
               "id" => id,
               "from_location_id" => 42,
               "quantity" => 42,
               "reference" => "some reference",
               "to_location_id" => 42,
               "uom_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.inventory_transfer_path(conn, :create), inventory_transfer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update inventory_transfer" do
    setup [:create_inventory_transfer]

    test "renders inventory_transfer when data is valid", %{conn: conn, inventory_transfer: %InventoryTransfer{id: id} = inventory_transfer} do
      conn = put(conn, Routes.inventory_transfer_path(conn, :update, inventory_transfer), inventory_transfer: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.inventory_transfer_path(conn, :show, id))

      assert %{
               "id" => id,
               "from_location_id" => 43,
               "quantity" => 43,
               "reference" => "some updated reference",
               "to_location_id" => 43,
               "uom_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, inventory_transfer: inventory_transfer} do
      conn = put(conn, Routes.inventory_transfer_path(conn, :update, inventory_transfer), inventory_transfer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete inventory_transfer" do
    setup [:create_inventory_transfer]

    test "deletes chosen inventory_transfer", %{conn: conn, inventory_transfer: inventory_transfer} do
      conn = delete(conn, Routes.inventory_transfer_path(conn, :delete, inventory_transfer))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.inventory_transfer_path(conn, :show, inventory_transfer))
      end
    end
  end

  defp create_inventory_transfer(_) do
    inventory_transfer = fixture(:inventory_transfer)
    %{inventory_transfer: inventory_transfer}
  end
end
