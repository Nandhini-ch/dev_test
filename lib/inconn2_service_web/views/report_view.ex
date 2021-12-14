defmodule Inconn2ServiceWeb.ReportView do
  use Inconn2ServiceWeb, :view
  # alias Inconn2ServiceWeb.ReportView

  def render("work_order_report.json", %{work_order_info: work_order_info}) do
    %{
      data: work_order_info
    }
  end

  def render("inventory_report.json", %{inventory_info: inventory_info}) do
    %{
      data: inventory_info
    }
  end
end
