defmodule Inconn2ServiceWeb.MeterReadingController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Measurements
  alias Inconn2Service.Measurements.MeterReading

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    meter_readings = Measurements.list_meter_readings(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", meter_readings: meter_readings)
  end

  def create(conn, %{"meter_reading" => meter_reading_params}) do
    with {:ok, %MeterReading{} = meter_reading} <- Measurements.create_meter_reading(meter_reading_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.meter_reading_path(conn, :show, meter_reading))
      |> render("show.json", meter_reading: meter_reading)
    end
  end

  def get_latest_cumulative_value_for_asset(conn, %{"asset_id" => asset_id, "asset_type" => asset_type, "unit_of_measurement" => unit_of_measurement}) do
    data = Measurements.get_last_cumulative_value(asset_id, asset_type, unit_of_measurement, conn.assigns.sub_domain_prefix)
    render(conn, "data.json", data: data)
  end

  # def show(conn, %{"id" => id}) do
  #   meter_reading = Measurements.get_meter_reading!(id)
  #   render(conn, "show.json", meter_reading: meter_reading)
  # end

  # def update(conn, %{"id" => id, "meter_reading" => meter_reading_params}) do
  #   meter_reading = Measurements.get_meter_reading!(id)

  #   with {:ok, %MeterReading{} = meter_reading} <- Measurements.update_meter_reading(meter_reading, meter_reading_params) do
  #     render(conn, "show.json", meter_reading: meter_reading)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   meter_reading = Measurements.get_meter_reading!(id)

  #   with {:ok, %MeterReading{}} <- Measurements.delete_meter_reading(meter_reading) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
