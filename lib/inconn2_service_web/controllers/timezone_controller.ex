defmodule Inconn2ServiceWeb.TimezoneController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Common
  alias Inconn2Service.Common.Timezone

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    timezones = Common.list_timezones()
    render(conn, "index.json", timezones: timezones)
  end

  def search(conn, %{"city" => city}) do
    timezones = Common.search_timezones(city)
    render(conn, "index.json", timezones: timezones)
  end

  def create(conn, %{"timezone" => timezone_params}) do
    with {:ok, %Timezone{} = timezone} <- Common.create_timezone(timezone_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("timezone", Routes.timezone_path(conn, :show, timezone))
      |> render("show.json", timezone: timezone)
    end
  end

end
