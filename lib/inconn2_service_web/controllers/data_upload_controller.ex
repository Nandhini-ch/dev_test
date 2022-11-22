defmodule Inconn2ServiceWeb.DataUploadController do
  use Inconn2ServiceWeb, :controller
  alias Inconn2Service.DataUploader

  def upload_content(conn, params) do
    data =
      DataUploader.process_bulk_upload(params["table"], params["csv_file"], conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{params["table"]}_upload_result.csv\"")
    |> send_resp(200, data)
  end
end
