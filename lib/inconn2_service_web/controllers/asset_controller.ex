defmodule Inconn2ServiceWeb.AssetController do
  use Inconn2ServiceWeb, :controller
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.SiteConfig
  alias Inconn2Service.Account
  Inconn2Service.AssetConfig.DuplicateEntry
  # alias Inconn2ServiceWeb.AssetView

  def get_asset_from_qr_code(conn, %{"qr_code" => qr_code}) do
    {_asset_type, asset} = AssetConfig.get_asset_from_qr_code(qr_code, conn.assigns.sub_domain_prefix)
    render(conn, "asset_details.json", asset: asset)
  end

  def get_locations_with_offset(conn, %{"site_id" => site_id}) do
    assets = AssetConfig.get_assets_with_offset("L", site_id, conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "locations_with_offset.json", asset_info: assets)
  end

  def get_equipments_with_offset(conn, %{"site_id" => site_id}) do
    assets = AssetConfig.get_assets_with_offset("E", site_id, conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "equipments_with_offset.json", asset_info: assets)
  end

#Manage Data Discrepancy

  alias Inconn2Service.Account
  alias Inconn2Service.AssetConfig.SiteConfig

  def manage_data_discrepancy(conn, _params) do
    licensees = Account.list_licensees()
    prefixes = Enum.map(licensees, fn x -> "inc_" <> x.sub_domain end)
    Enum.map(prefixes, fn prefix ->
      enum_licensee(prefix)
    end)
    success = %{success: "success"}
    render(conn, "success.json", success: success)
  end

  def enum_licensee(prefix) do
    query = from(sc in SiteConfig, where: is_nil(sc.type))
    site_configs = Repo.all(query, prefix: prefix)
    Enum.map(site_configs, fn x -> update_type(x, prefix) end)
    query = from(sc in SiteConfig)
    configs = Repo.all(query, prefix: prefix)
    configs = Enum.filter(configs, fn x -> x.type == "DASH" end)
    if length(configs) != 0 do
      [_ | t] = configs
      Enum.map(t, fn x -> AssetConfig.delete_site_config(x, prefix) end)
    else
      []
    end
  end

  defp update_type(site_config, prefix) do
    site_config
            |> SiteConfig.changeset(%{"type" => "DASH"})
            |> Repo.update(prefix: prefix)
  end

  #duplicate entry
  def index(conn, %{"table_name" => table_name, "prefix" => prefix}) do
    duplicate_entries = DuplicateEntry.get_duplicate_values_based_on_table_name(table_name, prefix)
    render(conn, "index.json", )
  end
end
