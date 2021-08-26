defmodule Inconn2ServiceWeb.PartyController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.Party

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    parties = AssetConfig.list_parties(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", parties: parties)
  end

  def create(conn, %{"party" => party_params}) do
    with {:ok, %Party{} = party} <- AssetConfig.create_party(party_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.party_path(conn, :show, party))
      |> render("show.json", party: party)
    end
  end

  def show(conn, %{"id" => id}) do
    party = AssetConfig.get_party!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", party: party)
  end

  def update(conn, %{"id" => id, "party" => party_params}) do
    party = AssetConfig.get_party!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Party{} = party} <-
           AssetConfig.update_party(party, party_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", party: party)
    end
  end

  def delete(conn, %{"id" => id}) do
    party = AssetConfig.get_party!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Party{}} <- AssetConfig.delete_party(party, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
