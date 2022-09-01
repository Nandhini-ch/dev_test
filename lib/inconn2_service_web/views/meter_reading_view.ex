defmodule Inconn2ServiceWeb.MeterReadingView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.MeterReadingView

  def render("index.json", %{meter_readings: meter_readings}) do
    %{data: render_many(meter_readings, MeterReadingView, "meter_reading.json")}
  end

  def render("show.json", %{meter_reading: meter_reading}) do
    %{data: render_one(meter_reading, MeterReadingView, "meter_reading.json")}
  end

  def render("meter_reading.json", %{meter_reading: meter_reading}) do
    %{id: meter_reading.id,
      site_id: meter_reading.site_id,
      asset_id: meter_reading.asset_id,
      asset_type: meter_reading.asset_type,
      recorded_date_time: meter_reading.recorded_date_time,
      unit_of_measurement: meter_reading.unit_of_measurement,
      absolute_value: meter_reading.absolute_value,
      cumulative_value: meter_reading.cumulative_value,
      meter_type: meter_reading.meter_type,
      work_order_id: meter_reading.work_order_id}
  end
end
