defmodule Inconn2ServiceWeb.WorkorderScheduleController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkorderSchedule

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    workorder_schedules = Workorder.list_workorder_schedules(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", workorder_schedules: workorder_schedules)
  end

  def create(conn, %{"workorder_schedule" => workorder_schedule_params, "zone" => zone}) do
    with {:ok, %WorkorderSchedule{} = workorder_schedule} <- Workorder.create_workorder_schedule(workorder_schedule_params, zone, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.workorder_schedule_path(conn, :show, workorder_schedule))
      |> render("show.json", workorder_schedule: workorder_schedule)
    end
  end

  def show(conn, %{"id" => id}) do
    workorder_schedule = Workorder.get_workorder_schedule!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", workorder_schedule: workorder_schedule)
  end

  def update(conn, %{"id" => id, "workorder_schedule" => workorder_schedule_params}) do
    workorder_schedule = Workorder.get_workorder_schedule!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderSchedule{} = workorder_schedule} <- Workorder.update_workorder_schedule(workorder_schedule, workorder_schedule_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", workorder_schedule: workorder_schedule)
    end
  end

  def next_schedule(conn, %{"id" => id}) do
    workorder_schedule = Workorder.get_workorder_schedule!(id, conn.assigns.sub_domain_prefix)

  #  with {:ok, %WorkorderSchedule{} = workorder_schedule} <- Workorder.update_workorder_schedule_and_scheduler(workorder_schedule, conn.assigns.sub_domain_prefix) do
  #    render(conn, "show.json", workorder_schedule: workorder_schedule)
  #  end
  #  with {_, nil} <- Workorder.update_workorder_schedule_and_scheduler(workorder_schedule, conn.assigns.sub_domain_prefix) do
  #    send_resp(conn, :no_content, "")
  #  end
    case IO.inspect(Workorder.update_workorder_schedule_and_scheduler(workorder_schedule, conn.assigns.sub_domain_prefix)) do
      {:ok, %WorkorderSchedule{} = workorder_schedule} ->
        render(conn, "show.json", workorder_schedule: workorder_schedule)

      {_, nil} ->
        send_resp(conn, :no_content, "")
    end
  end

  def delete(conn, %{"id" => id}) do
    workorder_schedule = Workorder.get_workorder_schedule!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderSchedule{}} <- Workorder.delete_workorder_schedule(workorder_schedule, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
