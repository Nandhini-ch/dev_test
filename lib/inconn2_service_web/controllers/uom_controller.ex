defmodule Inconn2ServiceWeb.UOMController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.UOM

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    uoms = Inventory.list_uoms(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", uoms: uoms)
  end

  def index_physical(conn, _params) do
    uoms = Inventory.list_physical_uoms(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", uoms: uoms)
  end

  def index_cost(conn, _params) do
    uoms = Inventory.list_cost_uoms(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", uoms: uoms)
  end

  def create(conn, %{"uom" => uom_params}) do
    with {:ok, %UOM{} = uom} <- Inventory.create_uom(uom_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.uom_path(conn, :show, uom))
      |> render("show.json", uom: uom)
    end
  end

  def show(conn, %{"id" => id}) do
    uom = Inventory.get_uom!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", uom: uom)
  end

  def update(conn, %{"id" => id, "uom" => uom_params}) do
    uom = Inventory.get_uom!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %UOM{} = uom} <- Inventory.update_uom(uom, uom_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", uom: uom)
    end
  end

  def delete(conn, %{"id" => id}) do
    uom = Inventory.get_uom!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %UOM{}} <- Inventory.delete_uom(uom, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
