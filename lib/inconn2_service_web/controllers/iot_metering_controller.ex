defmodule Inconn2ServiceWeb.IotMeteringController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Common
  alias Inconn2Service.Common.IotMetering

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    iot_meterings = Common.list_iot_meterings()
    render(conn, "index.json", iot_meterings: iot_meterings)
  end

  def create(conn, iot_metering_params) do
    with {:ok, %IotMetering{} = iot_metering} <- Common.create_iot_metering(iot_metering_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.iot_metering_path(conn, :show, iot_metering))
      |> render("show.json", iot_metering: iot_metering)
    end
  end

  def show(conn, %{"id" => id}) do
    iot_metering = Common.get_iot_metering!(id)
    render(conn, "show.json", iot_metering: iot_metering)
  end

  def update(conn, %{"id" => id, "iot_metering" => iot_metering_params}) do
    iot_metering = Common.get_iot_metering!(id)

    with {:ok, %IotMetering{} = iot_metering} <- Common.update_iot_metering(iot_metering, iot_metering_params) do
      render(conn, "show.json", iot_metering: iot_metering)
    end
  end

  def delete(conn, %{"id" => id}) do
    iot_metering = Common.get_iot_metering!(id)

    with {:ok, %IotMetering{}} <- Common.delete_iot_metering(iot_metering) do
      send_resp(conn, :no_content, "")
    end
  end
end
