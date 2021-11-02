defmodule Inconn2ServiceWeb.UomConversionController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.UomConversion

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    uom_conversions = Inventory.list_uom_conversions(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", uom_conversions: uom_conversions)
  end

  def create(conn, %{"uom_conversion" => uom_conversion_params}) do
    with {:ok, %UomConversion{} = uom_conversion} <- Inventory.create_uom_conversion(uom_conversion_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.uom_conversion_path(conn, :show, uom_conversion))
      |> render("show.json", uom_conversion: uom_conversion)
    end
  end

  def show(conn, %{"id" => id}) do
    uom_conversion = Inventory.get_uom_conversion!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", uom_conversion: uom_conversion)
  end

  def update(conn, %{"id" => id, "uom_conversion" => uom_conversion_params}) do
    uom_conversion = Inventory.get_uom_conversion!(id, conn.asssigns.sub_domain_prefix)

    with {:ok, %UomConversion{} = uom_conversion} <- Inventory.update_uom_conversion(uom_conversion, uom_conversion_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", uom_conversion: uom_conversion)
    end
  end

  def convert(conn, %{"from_uom_id" => from_uom_id, "to_uom_id" => to_uom_id, "value" => value}) do
    with {:ok, uom_conversion} <- Inventory.convert(from_uom_id, to_uom_id, value, conn.assigns.sub_domain_prefix) do
      render(conn, "convert.json", uom_conversion: uom_conversion)
    end
  end

  def delete(conn, %{"id" => id}) do
    uom_conversion = Inventory.get_uom_conversion!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %UomConversion{}} <- Inventory.delete_uom_conversion(uom_conversion, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
