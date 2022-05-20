defmodule Inconn2ServiceWeb.ManufacturerControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.Manufacturer

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

  def fixture(:manufacturer) do
    {:ok, manufacturer} = AssetInfo.create_manufacturer(@create_attrs)
    manufacturer
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all manufacturers", %{conn: conn} do
      conn = get(conn, Routes.manufacturer_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create manufacturer" do
    test "renders manufacturer when data is valid", %{conn: conn} do
      conn = post(conn, Routes.manufacturer_path(conn, :create), manufacturer: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.manufacturer_path(conn, :show, id))

      assert %{
               "id" => id,
               "contact" => %{},
               "description" => "some description",
               "name" => "some name",
               "register_no" => "some register_no"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.manufacturer_path(conn, :create), manufacturer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update manufacturer" do
    setup [:create_manufacturer]

    test "renders manufacturer when data is valid", %{conn: conn, manufacturer: %Manufacturer{id: id} = manufacturer} do
      conn = put(conn, Routes.manufacturer_path(conn, :update, manufacturer), manufacturer: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.manufacturer_path(conn, :show, id))

      assert %{
               "id" => id,
               "contact" => %{},
               "description" => "some updated description",
               "name" => "some updated name",
               "register_no" => "some updated register_no"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, manufacturer: manufacturer} do
      conn = put(conn, Routes.manufacturer_path(conn, :update, manufacturer), manufacturer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete manufacturer" do
    setup [:create_manufacturer]

    test "deletes chosen manufacturer", %{conn: conn, manufacturer: manufacturer} do
      conn = delete(conn, Routes.manufacturer_path(conn, :delete, manufacturer))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.manufacturer_path(conn, :show, manufacturer))
      end
    end
  end

  defp create_manufacturer(_) do
    manufacturer = fixture(:manufacturer)
    %{manufacturer: manufacturer}
  end
end
