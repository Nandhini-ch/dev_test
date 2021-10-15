defmodule Inconn2ServiceWeb.IotMeteringView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.IotMeteringView

  def render("index.json", %{iot_meterings: iot_meterings}) do
    %{data: render_many(iot_meterings, IotMeteringView, "iot_metering.json")}
  end

  def render("show.json", %{iot_metering: iot_metering}) do
    %{data: render_one(iot_metering, IotMeteringView, "iot_metering.json")}
  end

  def render("iot_metering.json", %{iot_metering: iot_metering}) do
    %{id: iot_metering.id,
      equipment_readings: iot_metering.equipment_readings,
      processed: iot_metering.processed}
  end
end
