defmodule Inconn2ServiceWeb.ManufacturerController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.Manufacturer

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    manufacturers = AssetInfo.list_manufacturers()
    render(conn, "index.json", manufacturers: manufacturers)
  end

  def create(conn, %{"manufacturer" => manufacturer_params}) do
    with {:ok, %Manufacturer{} = manufacturer} <- AssetInfo.create_manufacturer(manufacturer_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.manufacturer_path(conn, :show, manufacturer))
      |> render("show.json", manufacturer: manufacturer)
    end
  end

  def show(conn, %{"id" => id}) do
    manufacturer = AssetInfo.get_manufacturer!(id)
    render(conn, "show.json", manufacturer: manufacturer)
  end

  def update(conn, %{"id" => id, "manufacturer" => manufacturer_params}) do
    manufacturer = AssetInfo.get_manufacturer!(id)

    with {:ok, %Manufacturer{} = manufacturer} <- AssetInfo.update_manufacturer(manufacturer, manufacturer_params) do
      render(conn, "show.json", manufacturer: manufacturer)
    end
  end

  def delete(conn, %{"id" => id}) do
    manufacturer = AssetInfo.get_manufacturer!(id)

    with {:ok, %Manufacturer{}} <- AssetInfo.delete_manufacturer(manufacturer) do
      send_resp(conn, :no_content, "")
    end
  end
end
