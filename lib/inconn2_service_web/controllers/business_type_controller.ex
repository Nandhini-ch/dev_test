defmodule Inconn2ServiceWeb.BusinessTypeController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Account
  alias Inconn2Service.Account.BusinessType

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    business_types = Account.list_business_types()
    render(conn, "index.json", business_types: business_types)
  end

  def create(conn, %{"business_type" => business_type_params}) do
    with {:ok, %BusinessType{} = business_type} <-
           Account.create_business_type(business_type_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.business_type_path(conn, :show, business_type))
      |> render("show.json", business_type: business_type)
    end
  end

  def show(conn, %{"id" => id}) do
    business_type = Account.get_business_type!(id)
    render(conn, "show.json", business_type: business_type)
  end

  def update(conn, %{"id" => id, "business_type" => business_type_params}) do
    business_type = Account.get_business_type!(id)

    with {:ok, %BusinessType{} = business_type} <-
           Account.update_business_type(business_type, business_type_params) do
      render(conn, "show.json", business_type: business_type)
    end
  end

  def delete(conn, %{"id" => id}) do
    business_type = Account.get_business_type!(id)

    with {:ok, %BusinessType{}} <- Account.delete_business_type(business_type) do
      send_resp(conn, :no_content, "")
    end
  end
end
