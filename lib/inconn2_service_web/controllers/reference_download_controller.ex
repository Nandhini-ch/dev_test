defmodule Inconn2ServiceWeb.ReferenceDownloadController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.ReferenceDataDownloader
  action_fallback Inconn2ServiceWeb.FallbackController

  def download_locations(conn, _params) do
    data =
      ReferenceDataDownloader.download_locations(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"locations.csv\"")
    |> send_resp(200, data)
  end

  def download_equipments(conn, _params) do
    data =
      ReferenceDataDownloader.download_equipments(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"equipments.csv\"")
    |> send_resp(200, data)
  end

  def download_sites(conn, _params) do
    data =
      ReferenceDataDownloader.download_sites(conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"sites.csv\"")
    |> send_resp(200, data)
  end

end
