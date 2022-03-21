defmodule Inconn2ServiceWeb.AssetController do
  use Inconn2ServiceWeb, :controller
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.AssetConfig

  def get_asset_from_qr_code(conn, %{"qr_code" => qr_code}) do
    {_asset_type, asset} = AssetConfig.get_asset_from_qr_code(qr_code, conn.assigns.sub_domain_prefix)
    render(conn, "asset_details.json", asset: asset)
  end

  alias Inconn2Service.Workorder.WorkOrder
  alias Inconn2Service.Workorder
  alias Inconn2Service.Account

  def fill_asset_type_in_work_orders(conn, _params) do
    licensees = Account.list_licensees()
    prefixes = Enum.map(licensees, fn x -> "inc_" <> x.sub_domain end)
    Enum.map(prefixes, fn prefix ->
      enum_licensee(prefix)
    end)
    success = %{success: "success"}
    render(conn, "success.json", success: success)
  end

  def enum_licensee(prefix) do
    query = from(wo in WorkOrder, where: is_nil(wo.asset_type))
    work_orders = Repo.all(query, prefix: prefix)
    Enum.map(work_orders, fn x -> update_asset_type(x, prefix) end)
  end

  defp update_asset_type(work_order, prefix) do
    wot = Workorder.get_workorder_template!(work_order.workorder_template_id, prefix)
    work_order
            |> WorkOrder.changeset(%{"asset_type" => wot.asset_type})
            |> Repo.update(prefix: prefix)
  end

end
