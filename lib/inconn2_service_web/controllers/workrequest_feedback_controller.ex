defmodule Inconn2ServiceWeb.WorkrequestFeedbackController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.WorkrequestFeedback

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    workrequest_feedbacks = Ticket.list_workrequest_feedbacks(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", workrequest_feedbacks: workrequest_feedbacks)
  end

  def create(conn, %{"workrequest_feedback" => workrequest_feedback_params}) do
    with {:ok, %WorkrequestFeedback{} = workrequest_feedback} <- Ticket.create_workrequest_feedback(workrequest_feedback_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.workrequest_feedback_path(conn, :show, workrequest_feedback))
      |> render("show.json", workrequest_feedback: workrequest_feedback)
    end
  end

  def show(conn, %{"id" => id}) do
    workrequest_feedback = Ticket.get_workrequest_feedback!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", workrequest_feedback: workrequest_feedback)
  end

  def update(conn, %{"id" => id, "workrequest_feedback" => workrequest_feedback_params}) do
    workrequest_feedback = Ticket.get_workrequest_feedback!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkrequestFeedback{} = workrequest_feedback} <- Ticket.update_workrequest_feedback(workrequest_feedback, workrequest_feedback_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", workrequest_feedback: workrequest_feedback)
    end
  end

  def delete(conn, %{"id" => id}) do
    workrequest_feedback = Ticket.get_workrequest_feedback!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkrequestFeedback{}} <- Ticket.delete_workrequest_feedback(workrequest_feedback, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
