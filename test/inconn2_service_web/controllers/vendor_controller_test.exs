defmodule Inconn2ServiceWeb.VendorControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.Vendor

  @create_attrs %{
    contact: %{},
    description: "some description",
    name: "some name",
    register_no: "some register_no"
  }
  @update_attrs %{
    contact: %{},
    description: "some updated description",
    name: "some updated name",
    register_no: "some updated register_no"
  }
  @invalid_attrs %{contact: nil, description: nil, name: nil, register_no: nil}

  def fixture(:vendor) do
    {:ok, vendor} = AssetInfo.create_vendor(@create_attrs)
    vendor
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all vendors", %{conn: conn} do
      conn = get(conn, Routes.vendor_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create vendor" do
    test "renders vendor when data is valid", %{conn: conn} do
      conn = post(conn, Routes.vendor_path(conn, :create), vendor: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.vendor_path(conn, :show, id))

      assert %{
               "id" => id,
               "contact" => %{},
               "description" => "some description",
               "name" => "some name",
               "register_no" => "some register_no"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.vendor_path(conn, :create), vendor: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update vendor" do
    setup [:create_vendor]

    test "renders vendor when data is valid", %{conn: conn, vendor: %Vendor{id: id} = vendor} do
      conn = put(conn, Routes.vendor_path(conn, :update, vendor), vendor: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.vendor_path(conn, :show, id))

      assert %{
               "id" => id,
               "contact" => %{},
               "description" => "some updated description",
               "name" => "some updated name",
               "register_no" => "some updated register_no"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, vendor: vendor} do
      conn = put(conn, Routes.vendor_path(conn, :update, vendor), vendor: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete vendor" do
    setup [:create_vendor]

    test "deletes chosen vendor", %{conn: conn, vendor: vendor} do
      conn = delete(conn, Routes.vendor_path(conn, :delete, vendor))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.vendor_path(conn, :show, vendor))
      end
    end
  end

  defp create_vendor(_) do
    vendor = fixture(:vendor)
    %{vendor: vendor}
  end
end
