defmodule Inconn2ServiceWeb.PublicUomController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Common
  alias Inconn2Service.Common.PublicUom

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    public_uoms = Common.list_public_uoms()
    render(conn, "index.json", public_uoms: public_uoms)
  end

  def create(conn, %{"public_uom" => public_uom_params}) do
    with {:ok, %PublicUom{} = public_uom} <- Common.create_public_uom(public_uom_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.public_uom_path(conn, :show, public_uom))
      |> render("show.json", public_uom: public_uom)
    end
  end

  def show(conn, %{"id" => id}) do
    public_uom = Common.get_public_uom!(id)
    render(conn, "show.json", public_uom: public_uom)
  end

  def update(conn, %{"id" => id, "public_uom" => public_uom_params}) do
    public_uom = Common.get_public_uom!(id)

    with {:ok, %PublicUom{} = public_uom} <- Common.update_public_uom(public_uom, public_uom_params) do
      render(conn, "show.json", public_uom: public_uom)
    end
  end

  def delete(conn, %{"id" => id}) do
    public_uom = Common.get_public_uom!(id)

    with {:ok, %PublicUom{}} <- Common.delete_public_uom(public_uom) do
      send_resp(conn, :no_content, "")
    end
  end
end
