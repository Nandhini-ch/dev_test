defmodule Inconn2ServiceWeb.EquipmentManufacturerControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.EquipmentManufacturer

  @create_attrs %{
    acquired_date: ~D[2010-04-17],
    capacity: 120.5,
    commissioned_date: ~D[2010-04-17],
    country_of_origin: "some country_of_origin",
    depreciation_factor: 120.5,
    description: "some description",
    is_warranty_available: true,
    model_no: "some model_no",
    name: "some name",
    purchase_price: 120.5,
    serial_no: "some serial_no",
    unit_of_capacity: "some unit_of_capacity",
    warranty_from: ~D[2010-04-17],
    warranty_to: ~D[2010-04-17],
    year_of_manufacturing: 42
  }
  @update_attrs %{
    acquired_date: ~D[2011-05-18],
    capacity: 456.7,
    commissioned_date: ~D[2011-05-18],
    country_of_origin: "some updated country_of_origin",
    depreciation_factor: 456.7,
    description: "some updated description",
    is_warranty_available: false,
    model_no: "some updated model_no",
    name: "some updated name",
    purchase_price: 456.7,
    serial_no: "some updated serial_no",
    unit_of_capacity: "some updated unit_of_capacity",
    warranty_from: ~D[2011-05-18],
    warranty_to: ~D[2011-05-18],
    year_of_manufacturing: 43
  }
  @invalid_attrs %{acquired_date: nil, capacity: nil, commissioned_date: nil, country_of_origin: nil, depreciation_factor: nil, description: nil, is_warranty_available: nil, model_no: nil, name: nil, purchase_price: nil, serial_no: nil, unit_of_capacity: nil, warranty_from: nil, warranty_to: nil, year_of_manufacturing: nil}

  def fixture(:equipment_manufacturer) do
    {:ok, equipment_manufacturer} = AssetInfo.create_equipment_manufacturer(@create_attrs)
    equipment_manufacturer
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all equipment_manufacturers", %{conn: conn} do
      conn = get(conn, Routes.equipment_manufacturer_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create equipment_manufacturer" do
    test "renders equipment_manufacturer when data is valid", %{conn: conn} do
      conn = post(conn, Routes.equipment_manufacturer_path(conn, :create), equipment_manufacturer: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.equipment_manufacturer_path(conn, :show, id))

      assert %{
               "id" => id,
               "acquired_date" => "2010-04-17",
               "capacity" => 120.5,
               "commissioned_date" => "2010-04-17",
               "country_of_origin" => "some country_of_origin",
               "depreciation_factor" => 120.5,
               "description" => "some description",
               "is_warranty_available" => true,
               "model_no" => "some model_no",
               "name" => "some name",
               "purchase_price" => 120.5,
               "serial_no" => "some serial_no",
               "unit_of_capacity" => "some unit_of_capacity",
               "warranty_from" => "2010-04-17",
               "warranty_to" => "2010-04-17",
               "year_of_manufacturing" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.equipment_manufacturer_path(conn, :create), equipment_manufacturer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update equipment_manufacturer" do
    setup [:create_equipment_manufacturer]

    test "renders equipment_manufacturer when data is valid", %{conn: conn, equipment_manufacturer: %EquipmentManufacturer{id: id} = equipment_manufacturer} do
      conn = put(conn, Routes.equipment_manufacturer_path(conn, :update, equipment_manufacturer), equipment_manufacturer: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.equipment_manufacturer_path(conn, :show, id))

      assert %{
               "id" => id,
               "acquired_date" => "2011-05-18",
               "capacity" => 456.7,
               "commissioned_date" => "2011-05-18",
               "country_of_origin" => "some updated country_of_origin",
               "depreciation_factor" => 456.7,
               "description" => "some updated description",
               "is_warranty_available" => false,
               "model_no" => "some updated model_no",
               "name" => "some updated name",
               "purchase_price" => 456.7,
               "serial_no" => "some updated serial_no",
               "unit_of_capacity" => "some updated unit_of_capacity",
               "warranty_from" => "2011-05-18",
               "warranty_to" => "2011-05-18",
               "year_of_manufacturing" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, equipment_manufacturer: equipment_manufacturer} do
      conn = put(conn, Routes.equipment_manufacturer_path(conn, :update, equipment_manufacturer), equipment_manufacturer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete equipment_manufacturer" do
    setup [:create_equipment_manufacturer]

    test "deletes chosen equipment_manufacturer", %{conn: conn, equipment_manufacturer: equipment_manufacturer} do
      conn = delete(conn, Routes.equipment_manufacturer_path(conn, :delete, equipment_manufacturer))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.equipment_manufacturer_path(conn, :show, equipment_manufacturer))
      end
    end
  end

  defp create_equipment_manufacturer(_) do
    equipment_manufacturer = fixture(:equipment_manufacturer)
    %{equipment_manufacturer: equipment_manufacturer}
  end
end
