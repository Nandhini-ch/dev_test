defmodule Inconn2ServiceWeb.InventoryLocationControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.InventoryLocation

  @create_attrs %{
    description: "some description",
    name: "some name",
    site_id: 42,
    site_location_id: 42
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name",
    site_id: 43,
    site_location_id: 43
  }
  @invalid_attrs %{description: nil, name: nil, site_id: nil, site_location_id: nil}

  def fixture(:inventory_location) do
    {:ok, inventory_location} = Inventory.create_inventory_location(@create_attrs)
    inventory_location
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all inventory_locations", %{conn: conn} do
      conn = get(conn, Routes.inventory_location_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create inventory_location" do
    test "renders inventory_location when data is valid", %{conn: conn} do
      conn = post(conn, Routes.inventory_location_path(conn, :create), inventory_location: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.inventory_location_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "name" => "some name",
               "site_id" => 42,
               "site_location_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.inventory_location_path(conn, :create), inventory_location: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update inventory_location" do
    setup [:create_inventory_location]

    test "renders inventory_location when data is valid", %{conn: conn, inventory_location: %InventoryLocation{id: id} = inventory_location} do
      conn = put(conn, Routes.inventory_location_path(conn, :update, inventory_location), inventory_location: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.inventory_location_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "name" => "some updated name",
               "site_id" => 43,
               "site_location_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, inventory_location: inventory_location} do
      conn = put(conn, Routes.inventory_location_path(conn, :update, inventory_location), inventory_location: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete inventory_location" do
    setup [:create_inventory_location]

    test "deletes chosen inventory_location", %{conn: conn, inventory_location: inventory_location} do
      conn = delete(conn, Routes.inventory_location_path(conn, :delete, inventory_location))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.inventory_location_path(conn, :show, inventory_location))
      end
    end
  end

  defp create_inventory_location(_) do
    inventory_location = fixture(:inventory_location)
    %{inventory_location: inventory_location}
  end
end
