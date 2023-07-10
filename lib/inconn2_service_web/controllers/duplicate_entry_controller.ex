defmodule Inconn2ServiceWeb.DuplicateEntryController do

  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetConfig.DuplicateEntry
  action_fallback Inconn2ServiceWeb.FallbackController

  def download_duplicate_values(conn, %{"table_name" => table_name}) do
    data =
      DuplicateEntry.download_duplicate_values_based_on_table_name(table_name, conn.assigns.sub_domain_prefix)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{table_name}.csv\"")
    |> send_resp(200, data)
  end
end
