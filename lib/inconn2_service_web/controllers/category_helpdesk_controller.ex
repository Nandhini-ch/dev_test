defmodule Inconn2ServiceWeb.CategoryHelpdeskController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.CategoryHelpdesk

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    category_helpdesks = Ticket.list_category_helpdesks(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", category_helpdesks: category_helpdesks)
  end

  def create(conn, %{"category_helpdesk" => category_helpdesk_params}) do
    with {:ok, %CategoryHelpdesk{} = category_helpdesk} <- Ticket.create_category_helpdesk(category_helpdesk_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.category_helpdesk_path(conn, :show, category_helpdesk))
      |> render("show.json", category_helpdesk: category_helpdesk)
    end
  end

  def show(conn, %{"id" => id}) do
    category_helpdesk = Ticket.get_category_helpdesk!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", category_helpdesk: category_helpdesk)
  end

  def update(conn, %{"id" => id, "category_helpdesk" => category_helpdesk_params}) do
    category_helpdesk = Ticket.get_category_helpdesk!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %CategoryHelpdesk{} = category_helpdesk} <- Ticket.update_category_helpdesk(category_helpdesk, category_helpdesk_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", category_helpdesk: category_helpdesk)
    end
  end

  def delete(conn, %{"id" => id}) do
    category_helpdesk = Ticket.get_category_helpdesk!(id, conn.assigns.sub_domain_prefix)

    with {:deleted, _} <- Ticket.delete_category_helpdesk(category_helpdesk, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
