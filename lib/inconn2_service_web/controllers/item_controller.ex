defmodule Inconn2ServiceWeb.ItemController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Inventory
  alias Inconn2Service.Inventory.Item

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    items = Inventory.list_items(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", items: items)
  end

  def create(conn, %{"item" => item_params}) do
    with {:ok, %Item{} = item} <- Inventory.create_item(item_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.item_path(conn, :show, item))
      |> render("show.json", item: item)
    end
  end

  def show(conn, %{"id" => id}) do
    item = Inventory.get_item!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", item: item)
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    item = Inventory.get_item!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Item{} = item} <- Inventory.update_item(item, item_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", item: item)
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Inventory.get_item!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Item{}} <- Inventory.delete_item(item, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
