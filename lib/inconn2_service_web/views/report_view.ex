defmodule Inconn2ServiceWeb.ReportView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.ReportView

  def render("work_order_report.json", %{work_order_info: work_order_info}) do
    %{
      data: work_order_info
    }
  end

  def render("inventory_report.json", %{inventory_info: inventory_info}) do
    IO.inspect(inventory_info)
    %{
      data: render_many(inventory_info, ReportView, "inventory_report_item.json")
    }
  end

  def render("calendar.json", %{calendar: calendar}) do
    %{
      data: calendar
    }
  end

  def render("inventory_report_item.json", %{report: item}) do
    %{
      date: item.date,
      item_name: item.item_name,
      item_type: item.item_type,
      store_name: item.store_name,
      transaction_type: item.transaction_type,
      transaction_quantity: item.transaction_quantity,
      uom: item.uom,
      aisle: item.aisle,
      bin: item.bin,
      row: item.row,
      cost: item.cost
    }
  end
end
