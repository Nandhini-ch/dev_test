defmodule Inconn2ServiceWeb.UOMControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.UOM

  @create_attrs %{
    name: "some name",
    symbol: "some symbol"
  }
  @update_attrs %{
    name: "some updated name",
    symbol: "some updated symbol"
  }
  @invalid_attrs %{name: nil, symbol: nil}

  def fixture(:uom) do
    {:ok, uom} = Inventory.create_uom(@create_attrs)
    uom
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all uoms", %{conn: conn} do
      conn = get(conn, Routes.uom_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create uom" do
    test "renders uom when data is valid", %{conn: conn} do
      conn = post(conn, Routes.uom_path(conn, :create), uom: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.uom_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some name",
               "symbol" => "some symbol"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.uom_path(conn, :create), uom: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update uom" do
    setup [:create_uom]

    test "renders uom when data is valid", %{conn: conn, uom: %UOM{id: id} = uom} do
      conn = put(conn, Routes.uom_path(conn, :update, uom), uom: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.uom_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name",
               "symbol" => "some updated symbol"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, uom: uom} do
      conn = put(conn, Routes.uom_path(conn, :update, uom), uom: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete uom" do
    setup [:create_uom]

    test "deletes chosen uom", %{conn: conn, uom: uom} do
      conn = delete(conn, Routes.uom_path(conn, :delete, uom))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.uom_path(conn, :show, uom))
      end
    end
  end

  defp create_uom(_) do
    uom = fixture(:uom)
    %{uom: uom}
  end
end
