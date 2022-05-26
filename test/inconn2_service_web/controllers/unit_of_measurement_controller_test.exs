defmodule Inconn2ServiceWeb.UnitOfMeasurementControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.UnitOfMeasurement

  @create_attrs %{
    name: "some name",
    unit: "some unit"
  }
  @update_attrs %{
    name: "some updated name",
    unit: "some updated unit"
  }
  @invalid_attrs %{name: nil, unit: nil}

  def fixture(:unit_of_measurement) do
    {:ok, unit_of_measurement} = InventoryManagement.create_unit_of_measurement(@create_attrs)
    unit_of_measurement
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all unit_of_measurements", %{conn: conn} do
      conn = get(conn, Routes.unit_of_measurement_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create unit_of_measurement" do
    test "renders unit_of_measurement when data is valid", %{conn: conn} do
      conn = post(conn, Routes.unit_of_measurement_path(conn, :create), unit_of_measurement: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.unit_of_measurement_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some name",
               "unit" => "some unit"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.unit_of_measurement_path(conn, :create), unit_of_measurement: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update unit_of_measurement" do
    setup [:create_unit_of_measurement]

    test "renders unit_of_measurement when data is valid", %{conn: conn, unit_of_measurement: %UnitOfMeasurement{id: id} = unit_of_measurement} do
      conn = put(conn, Routes.unit_of_measurement_path(conn, :update, unit_of_measurement), unit_of_measurement: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.unit_of_measurement_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name",
               "unit" => "some updated unit"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, unit_of_measurement: unit_of_measurement} do
      conn = put(conn, Routes.unit_of_measurement_path(conn, :update, unit_of_measurement), unit_of_measurement: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete unit_of_measurement" do
    setup [:create_unit_of_measurement]

    test "deletes chosen unit_of_measurement", %{conn: conn, unit_of_measurement: unit_of_measurement} do
      conn = delete(conn, Routes.unit_of_measurement_path(conn, :delete, unit_of_measurement))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.unit_of_measurement_path(conn, :show, unit_of_measurement))
      end
    end
  end

  defp create_unit_of_measurement(_) do
    unit_of_measurement = fixture(:unit_of_measurement)
    %{unit_of_measurement: unit_of_measurement}
  end
end
