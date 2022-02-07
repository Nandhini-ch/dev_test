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

  def show(conn, %{"id" => id}) do
    workorder_schedule = Workorder.get_workorder_schedule!(id, conn.assigns.sub_domain_prefix)
    workorder_schedule = get_asset_and_site(workorder_schedule, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", workorder_schedule: workorder_schedule)
  end

  def update(conn, %{"id" => id, "workorder_schedule" => workorder_schedule_params}) do
    workorder_schedule = Workorder.get_workorder_schedule!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderSchedule{} = workorder_schedule} <- Workorder.update_workorder_schedule(workorder_schedule, workorder_schedule_params, conn.assigns.sub_domain_prefix) do
      workorder_schedule = get_asset_and_site(workorder_schedule, conn.assigns.sub_domain_prefix)
      render(conn, "show.json", workorder_schedule: workorder_schedule)
    end
  end

  def delete(conn, %{"id" => id}) do
    workorder_schedule = Workorder.get_workorder_schedule!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %WorkorderSchedule{}} <- Workorder.delete_workorder_schedule(workorder_schedule, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
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
