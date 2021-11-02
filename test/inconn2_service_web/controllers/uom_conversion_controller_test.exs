defmodule Inconn2ServiceWeb.UomConversionControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.UomConversion

  @create_attrs %{
    from_uom: 42,
    inverse_factor: 120.5,
    mult_factor: 120.5,
    to_uom: 42
  }
  @update_attrs %{
    from_uom: 43,
    inverse_factor: 456.7,
    mult_factor: 456.7,
    to_uom: 43
  }
  @invalid_attrs %{from_uom: nil, inverse_factor: nil, mult_factor: nil, to_uom: nil}

  def fixture(:uom_conversion) do
    {:ok, uom_conversion} = Inventory.create_uom_conversion(@create_attrs)
    uom_conversion
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all uom_conversions", %{conn: conn} do
      conn = get(conn, Routes.uom_conversion_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create uom_conversion" do
    test "renders uom_conversion when data is valid", %{conn: conn} do
      conn = post(conn, Routes.uom_conversion_path(conn, :create), uom_conversion: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.uom_conversion_path(conn, :show, id))

      assert %{
               "id" => id,
               "from_uom" => 42,
               "inverse_factor" => 120.5,
               "mult_factor" => 120.5,
               "to_uom" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.uom_conversion_path(conn, :create), uom_conversion: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update uom_conversion" do
    setup [:create_uom_conversion]

    test "renders uom_conversion when data is valid", %{conn: conn, uom_conversion: %UomConversion{id: id} = uom_conversion} do
      conn = put(conn, Routes.uom_conversion_path(conn, :update, uom_conversion), uom_conversion: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.uom_conversion_path(conn, :show, id))

      assert %{
               "id" => id,
               "from_uom" => 43,
               "inverse_factor" => 456.7,
               "mult_factor" => 456.7,
               "to_uom" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, uom_conversion: uom_conversion} do
      conn = put(conn, Routes.uom_conversion_path(conn, :update, uom_conversion), uom_conversion: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete uom_conversion" do
    setup [:create_uom_conversion]

    test "deletes chosen uom_conversion", %{conn: conn, uom_conversion: uom_conversion} do
      conn = delete(conn, Routes.uom_conversion_path(conn, :delete, uom_conversion))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.uom_conversion_path(conn, :show, uom_conversion))
      end
    end
  end

  defp create_uom_conversion(_) do
    uom_conversion = fixture(:uom_conversion)
    %{uom_conversion: uom_conversion}
  end
end
