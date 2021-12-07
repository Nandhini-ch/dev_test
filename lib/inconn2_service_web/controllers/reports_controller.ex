defmodule Inconn2ServiceWeb.ReportsController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Report

  action_fallback Inconn2ServiceWeb.FallbackController


  def get_work_order_report(conn, _params) do
    {:ok, pdf} = Report.get_work_order_report(conn.assigns.sub_domain_prefix)
    {:ok, binary} = File.read(pdf)
    conn
    |> put_resp_content_type("application/pdf")
    |> send_resp(200, binary)
  end
end
