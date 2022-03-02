defmodule Inconn2ServiceWeb.MeterReadingControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Measurements
  alias Inconn2Service.Measurements.MeterReading

  @create_attrs %{
    absolute_value: 120.5,
    asset_id: 42,
    asset_type: "some asset_type",
    cumulative_value: 120.5,
    recorded_date_time: ~N[2010-04-17 14:00:00],
    site_id: 42,
    unit_of_measurement: "some unit_of_measurement",
    work_order_id: 42
  }
  @update_attrs %{
    absolute_value: 456.7,
    asset_id: 43,
    asset_type: "some updated asset_type",
    cumulative_value: 456.7,
    recorded_date_time: ~N[2011-05-18 15:01:01],
    site_id: 43,
    unit_of_measurement: "some updated unit_of_measurement",
    work_order_id: 43
  }
  @invalid_attrs %{absolute_value: nil, asset_id: nil, asset_type: nil, cumulative_value: nil, recorded_date_time: nil, site_id: nil, unit_of_measurement: nil, work_order_id: nil}

  def fixture(:meter_reading) do
    {:ok, meter_reading} = Measurements.create_meter_reading(@create_attrs)
    meter_reading
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all meter_readings", %{conn: conn} do
      conn = get(conn, Routes.meter_reading_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create meter_reading" do
    test "renders meter_reading when data is valid", %{conn: conn} do
      conn = post(conn, Routes.meter_reading_path(conn, :create), meter_reading: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.meter_reading_path(conn, :show, id))

      assert %{
               "id" => id,
               "absolute_value" => 120.5,
               "asset_id" => 42,
               "asset_type" => "some asset_type",
               "cumulative_value" => 120.5,
               "recorded_date_time" => "2010-04-17T14:00:00",
               "site_id" => 42,
               "unit_of_measurement" => "some unit_of_measurement",
               "work_order_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.meter_reading_path(conn, :create), meter_reading: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update meter_reading" do
    setup [:create_meter_reading]

    test "renders meter_reading when data is valid", %{conn: conn, meter_reading: %MeterReading{id: id} = meter_reading} do
      conn = put(conn, Routes.meter_reading_path(conn, :update, meter_reading), meter_reading: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.meter_reading_path(conn, :show, id))

      assert %{
               "id" => id,
               "absolute_value" => 456.7,
               "asset_id" => 43,
               "asset_type" => "some updated asset_type",
               "cumulative_value" => 456.7,
               "recorded_date_time" => "2011-05-18T15:01:01",
               "site_id" => 43,
               "unit_of_measurement" => "some updated unit_of_measurement",
               "work_order_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, meter_reading: meter_reading} do
      conn = put(conn, Routes.meter_reading_path(conn, :update, meter_reading), meter_reading: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete meter_reading" do
    setup [:create_meter_reading]

    test "deletes chosen meter_reading", %{conn: conn, meter_reading: meter_reading} do
      conn = delete(conn, Routes.meter_reading_path(conn, :delete, meter_reading))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.meter_reading_path(conn, :show, meter_reading))
      end
    end
  end

  defp create_meter_reading(_) do
    meter_reading = fixture(:meter_reading)
    %{meter_reading: meter_reading}
  end
end
