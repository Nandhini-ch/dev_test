defmodule Inconn2ServiceWeb.ReferenceTemplateDownloaderController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.ReferenceTemplateDownloader
  action_fallback Inconn2ServiceWeb.FallbackController


  def download_template(conn, query_params) do
    data =
      ReferenceTemplateDownloader.download_template(conn.assigns.sub_domain_prefix, query_params)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"locations.csv\"")
    |> send_resp(200, data)
  end

end
