defmodule Inconn2ServiceWeb.StoreControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.Store

  @create_attrs %{
    aisle_count: 42,
    aisle_notation: "some aisle_notation",
    bin_count: 42,
    bin_notation: "some bin_notation",
    description: "some description",
    location_id: 42,
    name: "some name",
    row_count: 42,
    row_notation: "some row_notation"
  }
  @update_attrs %{
    aisle_count: 43,
    aisle_notation: "some updated aisle_notation",
    bin_count: 43,
    bin_notation: "some updated bin_notation",
    description: "some updated description",
    location_id: 43,
    name: "some updated name",
    row_count: 43,
    row_notation: "some updated row_notation"
  }
  @invalid_attrs %{aisle_count: nil, aisle_notation: nil, bin_count: nil, bin_notation: nil, description: nil, location_id: nil, name: nil, row_count: nil, row_notation: nil}

  def fixture(:store) do
    {:ok, store} = InventoryManagement.create_store(@create_attrs)
    store
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all stores", %{conn: conn} do
      conn = get(conn, Routes.store_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create store" do
    test "renders store when data is valid", %{conn: conn} do
      conn = post(conn, Routes.store_path(conn, :create), store: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.store_path(conn, :show, id))

      assert %{
               "id" => id,
               "aisle_count" => 42,
               "aisle_notation" => "some aisle_notation",
               "bin_count" => 42,
               "bin_notation" => "some bin_notation",
               "description" => "some description",
               "location_id" => 42,
               "name" => "some name",
               "row_count" => 42,
               "row_notation" => "some row_notation"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.store_path(conn, :create), store: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update store" do
    setup [:create_store]

    test "renders store when data is valid", %{conn: conn, store: %Store{id: id} = store} do
      conn = put(conn, Routes.store_path(conn, :update, store), store: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.store_path(conn, :show, id))

      assert %{
               "id" => id,
               "aisle_count" => 43,
               "aisle_notation" => "some updated aisle_notation",
               "bin_count" => 43,
               "bin_notation" => "some updated bin_notation",
               "description" => "some updated description",
               "location_id" => 43,
               "name" => "some updated name",
               "row_count" => 43,
               "row_notation" => "some updated row_notation"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, store: store} do
      conn = put(conn, Routes.store_path(conn, :update, store), store: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete store" do
    setup [:create_store]

    test "deletes chosen store", %{conn: conn, store: store} do
      conn = delete(conn, Routes.store_path(conn, :delete, store))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.store_path(conn, :show, store))
      end
    end
  end

  defp create_store(_) do
    store = fixture(:store)
    %{store: store}
  end
end
