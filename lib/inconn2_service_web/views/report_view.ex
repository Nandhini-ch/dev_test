defmodule Inconn2ServiceWeb.ReportView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{ReportView, WorkorderTaskView}

  def render("work_order_report.json", %{work_order_info: work_order_info, summary: summary}) do
    IO.inspect("213683704238")
    %{
      data: work_order_info,
      summary: summary
    }
  end

  def render("work_order_report.json", %{work_order_info: work_order_info}) do
    %{
      data: work_order_info
    }
  end

  def render("work_order_exec.json", %{work_order_exec_info: work_order_exec_info}) do
    %{
      data: render_many(work_order_exec_info, ReportView, "exec.json")
    }
  end

  def render("work_order_exec_meter.json", %{work_order_exec_info: work_order_exec_info}) do
    %{
      data: render_many(work_order_exec_info, ReportView, "exec_meter.json")
    }
  end

  def render("inventory_report.json", %{inventory_info: inventory_info, summary: summary}) do
    %{
      data: render_many(inventory_info, ReportView, "inventory_report_item.json"),
      summary: summary
    }
  end

  def render("people_report.json", %{people_info: people_info}) do
    %{
      data: render_many(people_info, ReportView, "people_report_item.json")
    }
  end

  def render("calendar.json", %{calendar: calendar}) do
    %{
      data: calendar
    }
  end

  def render("exec.json", %{report: wo}) do
    %{
      id: wo.id,
      site: wo.site.name,
      workorder_template: wo.workorder_template.name,
      asset: wo.asset.name,
      tasks: render_many(wo.tasks, WorkorderTaskView, "workorder_task_with_task.json")
    }
  end

  def render("exec_meter.json", %{report: wo}) do
    %{
      date: wo.recorded_date_time,
      site: wo.site.name,
      asset: wo.asset,
      asset_code: wo.asset_code,
      done_by: wo.done_by,
      within_range: nil
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
      cost: item.cost,
      reorder_level: item.reorder_level,
      supplier: item.supplier
    }
  end

  def render("people_report_item.json", %{report: item}) do
    %{
      first_name: item.first_name,
      last_name: item.last_name,
      designation: item.designation,
      emp_code: item.emp_code,
      attendance_percentage: item.attendance_percentage,
      work_done_time: item.work_done_time
    }
  end
end
