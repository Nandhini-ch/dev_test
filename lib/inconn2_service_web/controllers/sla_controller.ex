defmodule Inconn2ServiceWeb.SlaController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.ContractManagement
  alias Inconn2Service.Sla
  alias Inconn2Service.SlaCalculation

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    sla = ContractManagement.list_sla(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", sla: sla)
  end

  # def index(conn, %{"contract_id" => contract_id}) do
  #   sla = ContractManagement.list_sla(contract_id, conn.assigns.sub_domain_prefix)
  #   IO.inspect(sla)
  #   render(conn, "index.json", sla: sla)
  # end

  def create(conn, %{"sla" => sla_params}) do
    IO.inspect(sla_params)

    with {:ok, %Sla{} = sla} <-
           ContractManagement.create_sla(sla_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.contract_path(conn, :show, sla))
      |> render("show.json", sla: sla)
    end
  end

  def show(conn, %{"id" => id}) do
    sla = ContractManagement.get_sla!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", sla: sla)
  end

  def update(conn, %{"id" => id, "sla" => sla_params}) do
    IO.inspect(id)
    IO.inspect(sla_params)
    sla = ContractManagement.get_sla!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Sla{} = sla} <-
           ContractManagement.update_sla(
             sla,
             sla_params,
             conn.assigns.sub_domain_prefix
           ) do
      render(conn, "show.json", sla: sla)
    end
  end

  def activate_sla(conn, %{"id" => id}) do
    sla = ContractManagement.get_sla!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Sla{} = sla} <-
           ContractManagement.update_sla(
             sla,
             %{"active" => true},
             conn.assigns.sub_domain_prefix
           ) do
      render(conn, "show.json", sla: sla)
    end
  end

  def deactivate_sla(conn, %{"id" => id}) do
    sla = ContractManagement.get_sla!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Sla{} = sla} <-
           ContractManagement.update_sla(
             sla,
             %{"active" => false},
             conn.assigns.sub_domain_prefix
           ) do
      render(conn, "show.json", sla: sla)
    end
  end

  def scorecard_calculation(conn, %{
        "contract_id" => contract_id,
        "from_date" => from_date,
        "to_date" => to_date,
        "criteria" => criteria
      }) do
    prefix = conn.assigns.sub_domain_prefix

    result =
      case criteria do
        "Status-MTBF" ->
          SlaCalculation.get_mtbf_status(contract_id, from_date, to_date, prefix)

        "Status-MTTR" ->
          SlaCalculation.get_mttr_status(contract_id, from_date, to_date, prefix)

        "Movement completion percentage" ->
          SlaCalculation.movement_completion(contract_id, from_date, to_date, prefix)

        "Movement completion in-time percentage" ->
          SlaCalculation.movement_completion_in_time(contract_id, from_date, to_date, prefix)

        # "Tools audit" ->
        #   SlaCalculation.movement_completion_in_time(contract_id, from_date, to_date, prefix)

        "MSL breach" ->
          SlaCalculation.msl_breach(contract_id, from_date, to_date, prefix)

        "Zero stock level" ->
          SlaCalculation.zero_stock_level(contract_id, from_date, to_date, prefix)

        "Planned VS Completed" ->
          SlaCalculation.planned_vs_completed(contract_id, from_date, to_date, prefix)

        "On time completion" ->
          SlaCalculation.on_time_completion(contract_id, from_date, to_date, prefix)

        "Manual WO completion ratio" ->
          SlaCalculation.manual_wo_completion_ratio(contract_id, from_date, to_date, prefix)

        "AMC schedule adherence" ->
          SlaCalculation.amc_schedule_adherence(contract_id, from_date, to_date, prefix)

        "Planner" ->
          SlaCalculation.planner(contract_id, from_date, to_date, prefix)

        "On time reporting" ->
          SlaCalculation.on_time_reporting(contract_id, from_date, to_date, prefix)

        "Shift continuation" ->
          SlaCalculation.shift_continuation(contract_id, from_date, to_date, prefix)

        "Shift coverage" ->
          SlaCalculation.shift_coverage(contract_id, from_date, to_date, prefix)

        "Deployment status" ->
          SlaCalculation.deployment_status(contract_id, from_date, to_date, prefix)

        "Completion percentage" ->
          SlaCalculation.ticket_completion(contract_id, from_date, to_date, prefix)

        "TAT Adherence - Response" ->
          SlaCalculation.ticket_tat_response(contract_id, from_date, to_date, prefix)

        "TAT Adherence - Resolution" ->
          SlaCalculation.ticket_tat_resolution(contract_id, from_date, to_date, prefix)

        "Re-open percentage" ->
          SlaCalculation.ticket_reopen(contract_id, from_date, to_date, prefix)
      end

    IO.inspect(result)
    render(conn, "calculated_result.json", sla: result)
  end
end
