defmodule Inconn2ServiceWeb.AssetController do
  use Inconn2ServiceWeb, :controller
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.AssetConfig

  def get_asset_from_qr_code(conn, %{"qr_code" => qr_code}) do
    {_asset_type, asset} = AssetConfig.get_asset_from_qr_code(qr_code, conn.assigns.sub_domain_prefix)
    render(conn, "asset_details.json", asset: asset)
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
  end

  defp update_type(site_config, prefix) do
    site_config
            |> SiteConfig.changeset(%{"type" => "DASH"})
            |> Repo.update(prefix: prefix)
  end

end
