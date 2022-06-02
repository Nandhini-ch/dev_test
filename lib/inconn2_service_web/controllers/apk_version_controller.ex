defmodule Inconn2ServiceWeb.Apk_versionController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AppSettings
  alias Inconn2Service.AppSettings.Apk_version

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    apk_versions = AppSettings.list_apk_versions()
    render(conn, "index.json", apk_versions: apk_versions)
  end

  def create(conn, %{"apk_version" => apk_version_params}) do
    with {:ok, %Apk_version{} = apk_version} <- AppSettings.create_apk_version(apk_version_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.apk_version_path(conn, :show, apk_version))
      |> render("show.json", apk_version: apk_version)
    end
  end

  def show(conn, %{"id" => id}) do
    apk_version = AppSettings.get_apk_version!(id)
    render(conn, "show.json", apk_version: apk_version)
  end

end
