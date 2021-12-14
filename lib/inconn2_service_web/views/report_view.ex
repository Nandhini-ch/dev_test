defmodule Inconn2ServiceWeb.ReportView do
  use Inconn2ServiceWeb, :view
  # alias Inconn2ServiceWeb.ReportView

  def render("work_order_report.json", %{work_order_info: work_order_info}) do
    %{
      data: work_order_info
    }
  end
end
