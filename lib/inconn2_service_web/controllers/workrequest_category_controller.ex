defmodule Inconn2ServiceWeb.WorkrequestCategoryController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.WorkrequestCategory

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    workrequest_categories = Ticket.list_workrequest_categories(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", workrequest_categories: workrequest_categories)
  end

  def index_with_helpdesk_user(conn, _params) do
    workrequest_categories = Ticket.list_workrequest_categories_with_helpdesk_user(conn.assigns.sub_domain_prefix)
    render(conn, "index_with_helpdesk_user.json", workrequest_categories: workrequest_categories)
  end

  def create(conn, %{"workrequest_category" => workrequest_category_params}) do
    with {:ok, %WorkrequestCategory{} = workrequest_category} <- Ticket.create_workrequest_category(workrequest_category_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.workrequest_category_path(conn, :show, workrequest_category))
      |> render("show.json", workrequest_category: workrequest_category)
    end
  end

  def show(conn, %{"id" => id}) do
    workrequest_category = Ticket.get_workrequest_category!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", workrequest_category: workrequest_category)
  end

  def update(conn, %{"id" => id, "workrequest_category" => workrequest_category_params}) do
    workrequest_category = Ticket.get_workrequest_category!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkrequestCategory{} = workrequest_category} <- Ticket.update_workrequest_category(workrequest_category, workrequest_category_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", workrequest_category: workrequest_category)
    end
  end

  def delete(conn, %{"id" => id}) do
    workrequest_category = Ticket.get_workrequest_category!(id, conn.assigns.sub_domain_prefix)

    with {:deleted, _} <- Ticket.delete_workrequest_category(workrequest_category, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
