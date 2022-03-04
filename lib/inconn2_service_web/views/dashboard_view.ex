defmodule Inconn2ServiceWeb.DashboardView do
  use Inconn2ServiceWeb, :view

  def render("energy_meter.json", %{energy_meter_data: energy_meter_data}) do
    %{
      data: energy_meter_data
    }
  end

  def render("workflow_linear_data.json", %{workflow_data: workflow_data}) do
    %{
      data: workflow_data
    }
  end

  def render("workflow_linear_ticket_data", %{workflow_data: workflow_data}) do
    %{
      data: %{
        labels: workflow_data.labels,
        datasets: workflow_data.darasets,
        total_count: workflow_data.total_count,
        additional_information: %{
          reopened_tickets: render_many(workflow_data.additional_information.reopened_tickets, WorkRequestView, "work_request.json"),
          open_complaints_against_categories: workflow_data.additional_information.open_complaints_agains_category
        }
      }
    }
  end
  # def render("work_order_pie.json", %{work_order_counts: work_order_counts}) do
  #   %{
  #     data: %{
  #       completed_work_order_count: work_order_counts.completed_work_order_count,
  #       incomplete_work_order_count: work_order_counts.incomplete_work_order_count
  #     }
  #   }
  # end

  # def render("work_order_bar.json", %{work_order_counts: work_order_counts}) do
  #   %{
  #     data: %{
  #       dates: work_order_counts.dates,
  #       completed_work_order_count: work_order_counts.completed_work_order_count,
  #       incomplete_work_order_count: work_order_counts.incomplete_work_order_count
  #     }
  #   }
  # end

  # def render("asset_staus_pie.json", %{asset_status_data: asset_status_data}) do
  #   %{
  #     data: asset_status_data
  #   }
  # end

  # def render("workflow_pie_chart.json", %{workflow_data: workflow_data}) do
  #   %{
  #     data: workflow_data
  #   }
  # end

  # def render("metering_linear_chart.json", %{metering_linear_data: metering_linear_data}) do
  #   %{
  #     data: metering_linear_data
  #   }
  # end
end
