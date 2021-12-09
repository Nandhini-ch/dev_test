defmodule Inconn2ServiceWeb.WorkrequestSubcategoryController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.WorkrequestSubcategory

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    workrequest_subcategories = Ticket.list_workrequest_subcategories(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", workrequest_subcategories: workrequest_subcategories)
  end

  def index_for_category(conn, %{"workrequest_category_id" => workrequest_category_id}) do
    workrequest_subcategories = Ticket.list_workrequest_subcategories_for_category(workrequest_category_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", workrequest_subcategories: workrequest_subcategories)
  end

  def create(conn, %{"workrequest_subcategory" => workrequest_subcategory_params}) do
    with {:ok, %WorkrequestSubcategory{} = workrequest_subcategory} <- Ticket.create_workrequest_subcategory(workrequest_subcategory_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.workrequest_subcategory_path(conn, :show, workrequest_subcategory))
      |> render("show.json", workrequest_subcategory: workrequest_subcategory)
    end
  end

  def show(conn, %{"id" => id}) do
    workrequest_subcategory = Ticket.get_workrequest_subcategory!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", workrequest_subcategory: workrequest_subcategory)
  end

  def update(conn, %{"id" => id, "workrequest_subcategory" => workrequest_subcategory_params}) do
    workrequest_subcategory = Ticket.get_workrequest_subcategory!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkrequestSubcategory{} = workrequest_subcategory} <- Ticket.update_workrequest_subcategory(workrequest_subcategory, workrequest_subcategory_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", workrequest_subcategory: workrequest_subcategory)
    end
  end

  def delete(conn, %{"id" => id}) do
    workrequest_subcategory = Ticket.get_workrequest_subcategory!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkrequestSubcategory{}} <- Ticket.delete_workrequest_subcategory(workrequest_subcategory, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
