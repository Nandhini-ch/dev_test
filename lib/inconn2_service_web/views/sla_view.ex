defmodule Inconn2ServiceWeb.SlaView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.SlaView

  def render("index.json", %{sla: sla}) do
    IO.inspect(sla)
    %{data: render_many(sla, SlaView, "sla_index.json")}
  end

  def render("show.json", %{sla: sla}) do
    %{data: render_one(sla, SlaView, "sla.json")}
  end

  def render("sla.json", %{sla: sla}) do
    %{
      id: sla.id,
      category: sla.category,
      criteria: sla.criteria,
      kpi: sla.kpi,
      type: sla.type,
      approver: sla.approver,
      calculation: sla.calculation,
      weightage: sla.weightage,
      boolean_list: sla.boolean_list,
      range_list: sla.range_list,
      count_list: sla.count_list,
      contract_id: sla.contract_id,
      active: sla.active,
      exception: sla.exception,
      exception_value: sla.exception_value,
      justification: sla.justification,
      cycle: sla.cycle,
      status: sla.status,
      created_at: sla.inserted_at,
      config_status: sla.config_status,
      rejection_reason: sla.rejection_reason,
    }
  end

  def render("sla_index.json", %{sla: sla}) do
    %{
      id: sla.id,
      category: sla.category,
      criteria: sla.criteria,
      kpi: sla.kpi,
      type: sla.type,
      approver: sla.approver,
      calculation: sla.calculation,
      weightage: sla.weightage,
      boolean_list: sla.boolean_list,
      range_list: sla.range_list,
      count_list: sla.count_list,
      contract_id: sla.contract_id,
      active: sla.active,
      exception: sla.exception,
      exception_value: sla.exception_value,
      justification: sla.justification,
      cycle: sla.cycle,
      status: sla.status,
      approver_name: sla.approver_name,
      created_at: sla.inserted_at,
      config_status: sla.config_status,
      rejection_reason: sla.rejection_reason,
    }
  end

  def render("calculated_result.json", %{sla: sla}) do
    %{data: render_one(sla, SlaView, "sla_calculation.json")}
  end

  def render("sla_calculation.json", %{sla: sla}) do
    %{data: sla}
  end
end
