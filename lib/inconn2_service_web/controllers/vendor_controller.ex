defmodule Inconn2ServiceWeb.VendorController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.Vendor

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    vendors = AssetInfo.list_vendors(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", vendors: vendors)
  end

  def create(conn, %{"vendor" => vendor_params}) do
    with {:ok, %Vendor{} = vendor} <- AssetInfo.create_vendor(vendor_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.vendor_path(conn, :show, vendor))
      |> render("show.json", vendor: vendor)
    end
  end

  def show(conn, %{"id" => id}) do
    vendor = AssetInfo.get_vendor!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", vendor: vendor)
  end

  def update(conn, %{"id" => id, "vendor" => vendor_params}) do
    vendor = AssetInfo.get_vendor!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Vendor{} = vendor} <- AssetInfo.update_vendor(vendor, vendor_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", vendor: vendor)
    end
  end

  def delete(conn, %{"id" => id}) do
    vendor = AssetInfo.get_vendor!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Vendor{}} <- AssetInfo.delete_vendor(vendor, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
