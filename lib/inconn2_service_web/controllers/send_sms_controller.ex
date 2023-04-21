defmodule Inconn2ServiceWeb.SendSmsController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Communication
  alias Inconn2Service.Communication.SendSms

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    send_sms = Communication.list_send_sms()
    render(conn, "index.json", send_sms: send_sms)
  end

  def create(conn, %{"send_sms" => send_sms_params}) do
    with {:ok, %SendSms{} = send_sms} <- Communication.create_send_sms(send_sms_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.send_sms_path(conn, :show, send_sms))
      |> render("show.json", send_sms: send_sms)
    end
  end

  def show(conn, %{"id" => id}) do
    send_sms = Communication.get_send_sms!(id)
    render(conn, "show.json", send_sms: send_sms)
  end

  def update(conn, %{"id" => id, "send_sms" => send_sms_params}) do
    send_sms = Communication.get_send_sms!(id)

    with {:ok, %SendSms{} = send_sms} <- Communication.update_send_sms(send_sms, send_sms_params) do
      render(conn, "show.json", send_sms: send_sms)
    end
  end

  def delete(conn, %{"id" => id}) do
    send_sms = Communication.get_send_sms!(id)

    with {:ok, %SendSms{}} <- Communication.delete_send_sms(send_sms) do
      send_resp(conn, :no_content, "")
    end
  end
end
