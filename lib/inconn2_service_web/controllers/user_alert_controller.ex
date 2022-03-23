defmodule Inconn2ServiceWeb.UserAlertController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Prompt
  alias Inconn2Service.Prompt.UserAlert

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    user_alerts = Prompt.list_user_alerts(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", user_alerts: user_alerts)
  end

  def create(conn, %{"user_alert" => user_alert_params}) do
    with {:ok, %UserAlert{} = user_alert} <- Prompt.create_user_alert(user_alert_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_alert_path(conn, :show, user_alert))
      |> render("show.json", user_alert: user_alert)
    end
  end

  def show(conn, %{"id" => id}) do
    user_alert = Prompt.get_user_alert!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", user_alert: user_alert)
  end

  def update(conn, %{"id" => id, "user_alert" => user_alert_params}) do
    user_alert = Prompt.get_user_alert!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %UserAlert{} = user_alert} <- Prompt.update_user_alert(user_alert, user_alert_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", user_alert: user_alert)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_alert = Prompt.get_user_alert!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %UserAlert{}} <- Prompt.delete_user_alert(user_alert, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
