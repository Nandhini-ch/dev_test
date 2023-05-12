defmodule Inconn2ServiceWeb.WorkorderScheduleController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkorderSchedule
  alias Inconn2Service.AssetConfig

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    workorder_schedules = Workorder.list_workorder_schedules(conn.assigns.sub_domain_prefix)
    workorder_schedules = Enum.map(workorder_schedules, fn workorder_schedule ->
                                          get_asset_and_site(workorder_schedule, conn.assigns.sub_domain_prefix)
                                  end)
    render(conn, "index.json", workorder_schedules: workorder_schedules)
  end

  def create(conn, %{"workorder_schedule" => workorder_schedule_params}) do
    with {:ok, %WorkorderSchedule{} = workorder_schedule} <- Workorder.create_workorder_schedule(workorder_schedule_params, conn.assigns.sub_domain_prefix) do
      workorder_schedule = get_asset_and_site(workorder_schedule, conn.assigns.sub_domain_prefix)
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.workorder_schedule_path(conn, :show, workorder_schedule))
      |> render("show.json", workorder_schedule: workorder_schedule)
    end
  end

  def create_multiple(conn, %{"workorder_schedules" => workorder_schedule_params}) do
    with {:ok, workorder_schedules} <- Workorder.create_workorder_schedules(workorder_schedule_params, conn.assigns.sub_domain_prefix) do
      workorder_schedules = Enum.map(workorder_schedules, fn workorder_schedule ->
        get_asset_and_site(workorder_schedule, conn.assigns.sub_domain_prefix)
      end)
      conn
      |> put_status(:created)
      |> render("index.json", workorder_schedules: workorder_schedules)
    end
  end

  def show(conn, %{"id" => id}) do
    workorder_schedule = Workorder.get_workorder_schedule!(id, conn.assigns.sub_domain_prefix)
    workorder_schedule = get_asset_and_site(workorder_schedule, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", workorder_schedule: workorder_schedule)
  end

  def update(conn, %{"id" => id, "workorder_schedules" => workorder_schedule_params}) do
    workorder_schedule = Workorder.get_workorder_schedule!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderSchedule{} = workorder_schedule} <- Workorder.update_workorder_schedule(workorder_schedule, workorder_schedule_params, conn.assigns.current_user, conn.assigns.sub_domain_prefix) do
      workorder_schedule = get_asset_and_site(workorder_schedule, conn.assigns.sub_domain_prefix)
      render(conn, "show.json", workorder_schedule: workorder_schedule)
    end
  end

  def update_multiple(conn, %{"workorder_schedules" => workorder_schedule_params}) do
    with {:ok, workorder_schedules} <- Workorder.update_workorder_schedules(workorder_schedule_params, conn.assigns.current_user, conn.assigns.sub_domain_prefix) do
      workorder_schedules = Enum.map(workorder_schedules, fn workorder_schedule ->
        get_asset_and_site(workorder_schedule, conn.assigns.sub_domain_prefix)
      end)
      conn
      |> put_status(:ok)
      |> render("index.json", workorder_schedules: workorder_schedules)
    end
  end

  def pause_resume_multiple(conn, %{"workorder_schedules" => workorder_schedule_params}) do
    with {:ok, workorder_schedules} <- Workorder.multiple_update_pause_schedule(workorder_schedule_params, conn.assigns.sub_domain_prefix) do
      workorder_schedules = Enum.map(workorder_schedules, fn workorder_schedule ->
        get_asset_and_site(workorder_schedule, conn.assigns.sub_domain_prefix)
      end)
      conn
      |> put_status(:ok)
      |> render("index.json", workorder_schedules: workorder_schedules)
    end
  end

  def delete(conn, %{"id" => id}) do
    workorder_schedule = Workorder.get_workorder_schedule!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderSchedule{}} <- Workorder.deactivate_workorder_schedule(workorder_schedule, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

  def pause_schedule(conn, %{"id" => id}) do
    workorder_schedule = Workorder.get_workorder_schedule!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderSchedule{} = workorder_schedule} <- Workorder.pause_or_resume_workorder_schedule(workorder_schedule, %{"is_paused" => true}, conn.assigns.sub_domain_prefix) do
      workorder_schedule = get_asset_and_site(workorder_schedule, conn.assigns.sub_domain_prefix)
      render(conn, "show.json", workorder_schedule: workorder_schedule)
    end
  end

  def resume_schedule(conn, %{"id" => id, "workorder_schedule" => workorder_schedule_params}) do
    workorder_schedule = Workorder.get_workorder_schedule!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderSchedule{} = workorder_schedule} <- Workorder.pause_or_resume_workorder_schedule(workorder_schedule, Map.put(workorder_schedule_params, "is_paused", false), conn.assigns.sub_domain_prefix) do
      workorder_schedule = get_asset_and_site(workorder_schedule, conn.assigns.sub_domain_prefix)
      render(conn, "show.json", workorder_schedule: workorder_schedule)
    end
  end

  defp get_asset_and_site(workorder_schedule, prefix) do
    asset_id = workorder_schedule.asset_id
    case workorder_schedule.asset_type do
      "L" -> location = AssetConfig.get_location!(asset_id, prefix)
             site = AssetConfig.get_site!(location.site_id, prefix)
             Map.put_new(workorder_schedule, :site, site)
             |> Map.put_new(:asset, location)
      "E" -> equipment = AssetConfig.get_equipment!(asset_id, prefix)
             site = AssetConfig.get_site!(equipment.site_id, prefix)
             Map.put_new(workorder_schedule, :site, site)
             |> Map.put_new(:asset, equipment)
    end
  end
end
