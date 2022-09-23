defmodule Inconn2ServiceWeb.SiteStockControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.SiteStock

  @create_attrs %{
    breached_date_time: ~N[2010-04-17 14:00:00],
    is_msl_breached: "some is_msl_breached",
    quantity: 120.5
  }
  @update_attrs %{
    breached_date_time: ~N[2011-05-18 15:01:01],
    is_msl_breached: "some updated is_msl_breached",
    quantity: 456.7
  }
  @invalid_attrs %{breached_date_time: nil, is_msl_breached: nil, quantity: nil}

  def fixture(:site_stock) do
    {:ok, site_stock} = InventoryManagement.create_site_stock(@create_attrs)
    site_stock
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all site_stocks", %{conn: conn} do
      conn = get(conn, Routes.site_stock_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create site_stock" do
    test "renders site_stock when data is valid", %{conn: conn} do
      conn = post(conn, Routes.site_stock_path(conn, :create), site_stock: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.site_stock_path(conn, :show, id))

      assert %{
               "id" => id,
               "breached_date_time" => "2010-04-17T14:00:00",
               "is_msl_breached" => "some is_msl_breached",
               "quantity" => 120.5
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.site_stock_path(conn, :create), site_stock: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update site_stock" do
    setup [:create_site_stock]

    test "renders site_stock when data is valid", %{conn: conn, site_stock: %SiteStock{id: id} = site_stock} do
      conn = put(conn, Routes.site_stock_path(conn, :update, site_stock), site_stock: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.site_stock_path(conn, :show, id))

      assert %{
               "id" => id,
               "breached_date_time" => "2011-05-18T15:01:01",
               "is_msl_breached" => "some updated is_msl_breached",
               "quantity" => 456.7
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, site_stock: site_stock} do
      conn = put(conn, Routes.site_stock_path(conn, :update, site_stock), site_stock: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete site_stock" do
    setup [:create_site_stock]

    test "deletes chosen site_stock", %{conn: conn, site_stock: site_stock} do
      conn = delete(conn, Routes.site_stock_path(conn, :delete, site_stock))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.site_stock_path(conn, :show, site_stock))
      end
    end
  end

  defp create_site_stock(_) do
    site_stock = fixture(:site_stock)
    %{site_stock: site_stock}
  end
end
