defmodule Inconn2ServiceWeb.LicenseeController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Account
  alias Inconn2Service.Account.Licensee

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    licensees = Account.list_licensees()
    render(conn, "index.json", licensees: licensees)
  end

  def create(conn, %{"licensee" => licensee_params}) do
    with {:ok, %Licensee{} = licensee} <- Account.create_licensee(licensee_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.licensee_path(conn, :show, licensee))
      |> render("show.json", licensee: licensee)
    end
  end

  def show(conn, %{"id" => id}) do
    licensee = Account.get_licensee!(id)
    render(conn, "show.json", licensee: licensee)
  end

  def update(conn, %{"id" => id, "licensee" => licensee_params}) do
    licensee = Account.get_licensee!(id)

    with {:ok, %Licensee{} = licensee} <- Account.update_licensee(licensee, licensee_params) do
      render(conn, "show.json", licensee: licensee)
    end
  end

  def delete(conn, %{"id" => id}) do
    licensee = Account.get_licensee!(id)

    with {:ok, %Licensee{}} <- Account.delete_licensee(licensee) do
      send_resp(conn, :no_content, "")
    end
  end
end
