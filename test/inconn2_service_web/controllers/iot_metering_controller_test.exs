defmodule Inconn2ServiceWeb.IotMeteringControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Common
  alias Inconn2Service.Common.IotMetering

  @create_attrs %{
    equipment_readings: %{},
    processed: true
  }
  @update_attrs %{
    equipment_readings: %{},
    processed: false
  }
  @invalid_attrs %{equipment_readings: nil, processed: nil}

  def fixture(:iot_metering) do
    {:ok, iot_metering} = Common.create_iot_metering(@create_attrs)
    iot_metering
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all iot_meterings", %{conn: conn} do
      conn = get(conn, Routes.iot_metering_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create iot_metering" do
    test "renders iot_metering when data is valid", %{conn: conn} do
      conn = post(conn, Routes.iot_metering_path(conn, :create), iot_metering: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.iot_metering_path(conn, :show, id))

      assert %{
               "id" => id,
               "equipment_readings" => %{},
               "processed" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.iot_metering_path(conn, :create), iot_metering: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update iot_metering" do
    setup [:create_iot_metering]

    test "renders iot_metering when data is valid", %{conn: conn, iot_metering: %IotMetering{id: id} = iot_metering} do
      conn = put(conn, Routes.iot_metering_path(conn, :update, iot_metering), iot_metering: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.iot_metering_path(conn, :show, id))

      assert %{
               "id" => id,
               "equipment_readings" => %{},
               "processed" => false
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, iot_metering: iot_metering} do
      conn = put(conn, Routes.iot_metering_path(conn, :update, iot_metering), iot_metering: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete iot_metering" do
    setup [:create_iot_metering]

    test "deletes chosen iot_metering", %{conn: conn, iot_metering: iot_metering} do
      conn = delete(conn, Routes.iot_metering_path(conn, :delete, iot_metering))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.iot_metering_path(conn, :show, iot_metering))
      end
    end
  end

  defp create_iot_metering(_) do
    iot_metering = fixture(:iot_metering)
    %{iot_metering: iot_metering}
  end
end
