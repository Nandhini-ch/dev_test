defmodule Inconn2ServiceWeb.MyReportView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.MyReportView

  def render("index.json", %{my_reports: my_reports}) do
    %{data: render_many(my_reports, MyReportView, "my_report.json")}
  end

  def render("show.json", %{my_report: my_report}) do
    %{data: render_one(my_report, MyReportView, "my_report.json")}
  end

  def render("my_report.json", %{my_report: my_report}) do
    %{id: my_report.id,
      name: my_report.name,
      description: my_report.description,
      code: my_report.code,
      report_params: my_report.report_params}
  end
end
