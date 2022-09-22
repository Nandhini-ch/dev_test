defmodule Inconn2Service.Dashboards.NumericalData do
  import Ecto.Query, warn: false
  import Inconn2Service.Util.IndexQueries
  alias Inconn2Service.Repo

  alias Inconn2Service.Measurements.MeterReading
  alias Inconn2Service.AssetConfig.{Equipment, Site}
  alias Inconn2Service.Workorder.WorkorderTemplate
  alias Inconn2Service.Workorder.{WorkOrder, WorkorderSchedule}
  alias Inconn2Service.AssetConfig.{AssetCategory, Equipment, AssetStatusTrack}
  alias Inconn2Service.Ticket.WorkRequest


  def get_energy_consumption_for_assets(nil, _from_dt, _to_dt, _prefix), do: 0
  def get_energy_consumption_for_assets(asset_ids, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.asset_id in ^asset_ids and
                        mr.asset_type == "E" and
                        mr.meter_type == "E" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_water_consumption_for_assets(nil, _from_dt, _to_dt, _prefix), do: 0
  def get_water_consumption_for_assets(asset_ids, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.asset_id in ^asset_ids and
                        mr.asset_type == "E" and
                        mr.meter_type == "W" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_fuel_consumption_for_assets(nil, _from_dt, _to_dt, _prefix), do: 0
  def get_fuel_consumption_for_assets(asset_ids, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.asset_id in ^asset_ids and
                        mr.asset_type == "E" and
                        mr.meter_type == "F" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_energy_consumption_for_asset(asset_id, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.asset_id == ^asset_id and
                        mr.asset_type == "E" and
                        mr.meter_type == "E" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_water_consumption_for_asset(asset_id, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.asset_id == ^asset_id and
                        mr.asset_type == "E" and
                        mr.meter_type == "W" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end


  def get_fuel_consumption_for_asset(asset_id, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.asset_id == ^asset_id and
                        mr.asset_type == "E" and
                        mr.meter_type == "F" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_energy_consumption_for_site(site_id, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.site_id == ^site_id and
                        mr.asset_type == "E" and
                        mr.meter_type == "E" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_energy_consumption_for_site(site_id, exclude_asset_ids, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.site_id == ^site_id and
                        mr.asset_id not in ^exclude_asset_ids and
                        mr.asset_type == "E" and
                        mr.meter_type == "E" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_for_workorder_count(site_id, from_date, to_date, prefix) do
    get_workorder_general_query(site_id, from_date, to_date) |> Repo.all(prefix: prefix)
  end

  def get_workorder_for_chart(site_id, from_date, to_date, asset_category_ids, nil, _asset_type, statuses, inclusion, type, prefix) do
    query = get_workorder_general_query(site_id, from_date, to_date) |> add_status_filter_to_query(statuses, inclusion) |> add_workorder_type_filter_to_query(type)
    from(q in query, join: wot in WorkorderTemplate, on: q.workorder_template_id == wot.id,
                     join: ac in AssetCategory, on: ac.id == wot.asset_category_id and wot.asset_category_id in ^asset_category_ids,
                     select: %{
                      asset_category_id: ac.id,
                      asset_category_name: ac.name,
                      work_order: q
                     })
    |> Repo.all(prefix: prefix)
  end

  def get_workorder_for_chart(site_id, from_date, to_date, nil, asset_ids, asset_type, statuses, inclusion, type, prefix) do
    query = get_workorder_general_query(site_id, from_date, to_date) |> add_status_filter_to_query(statuses, inclusion) |> add_workorder_type_filter_to_query(type)
    from(q in query, where: q.asset_id in ^asset_ids and q.asset_type == ^asset_type)

    |> Repo.all(prefix: prefix)
  end

  def get_workorder_for_chart(site_id, from_date, to_date, statuses, inclusion, type, prefix) do
    get_workorder_general_query(site_id, from_date, to_date)
    |> add_status_filter_to_query(statuses, inclusion)
    |> add_workorder_type_filter_to_query(type)
    |> Repo.all(prefix: prefix)
  end

  def get_work_requests(site_id, params, from_datetime, to_datetime, statuses, inclusion, prefix) do
    get_work_request_general_query(site_id, from_datetime, to_datetime)
    |> work_request_query(params)
    |> add_status_filter_to_query(statuses, inclusion)
    |> Repo.all(prefix: prefix)
    |> Repo.preload([:workrequest_category])
  end

  def get_work_requests(site_id, from_datetime, to_datetime, statuses, inclusion, prefix) do
    get_work_request_general_query(site_id, from_datetime, to_datetime)
    |> add_status_filter_to_query(statuses, inclusion)
    |> Repo.all(prefix: prefix)
  end

  def open_workorders(site_id, from_date, to_date, prefix) do
    add_status_filter_to_query(get_workorder_general_query(site_id, from_date, to_date), ["cr"], "in")
    |> Repo.all(prefix: prefix)
  end

  def progressing_workorders(site_id, from_date, to_date, type, prefix) do
    get_workorder_general_query(site_id, from_date, to_date)
    |> add_status_filter_to_query(["cp", "cn"], "not")
    |> add_workorder_type_filter_to_query(type)
    |> Repo.all(prefix: prefix)
  end

  def in_progress_workorders(site_id, from_date, to_date, prefix) do
    add_status_filter_to_query(get_workorder_general_query(site_id, from_date, to_date), ["cn", "cr", "as"], "not")
    |> Repo.all(prefix: prefix)
  end

  def completed_workorders(site_id, from_date, to_date, type, prefix) do
    get_workorder_general_query(site_id, from_date, to_date)
    |> add_status_filter_to_query(["cp"], "in")
    |> add_workorder_type_filter_to_query(type)
    |> Repo.all(prefix: prefix)
  end

  def get_open_tickets(site_id, from_datetime, to_datetime, prefix) do
    add_status_filter_to_query(get_work_request_general_query(site_id, from_datetime, to_datetime), ["CP", "CS"], "not")
    |> Repo.all(prefix: prefix)
  end

  def inprogress_tickets(site_id, from_datetime, to_datetime, prefix) do
    add_status_filter_to_query(get_work_request_general_query(site_id, from_datetime, to_datetime), ["RS", "CP", "CS"], "not")
    |> Repo.all(prefix: prefix)
  end

  def get_close_tickets(site_id, from_datetime, to_datetime) do
    add_status_filter_to_query(get_work_request_general_query(site_id, from_datetime, to_datetime), ["CP"], "in")
  end

  # def get_open_ticket_chart(site_id, from_datetime, to_datetime, ticket_category_ids) do
  #   query = get_open_tickets(site_id, from_datetime, to_datetime)
  #   from(q in query, where: q.workrequest_category_id in ^ticket_category_ids)
  # end

  def get_close_ticket_chart(site_id, from_datetime, to_datetime, ticket_category_ids) do
    query = get_close_tickets(site_id, from_datetime, to_datetime)
    from(q in query, where: q.workrequest_category_id in ^ticket_category_ids)
  end

  # def service_workorder_status_chart(site_id, from_date, to_date, )

  defp get_workorder_general_query(site_id, from_date, to_date) do
    from(wo in WorkOrder, where: wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date and wo.site_id == ^site_id)
  end

  defp get_work_request_general_query(site_id, from_datetime, to_datetime) do
    from(wr in WorkRequest, where: wr.raised_date_time >= ^from_datetime and wr.raised_date_time <= ^to_datetime and wr.site_id == ^site_id)
  end

  defp add_status_filter_to_query(query, statuses, inclusion) do
    case inclusion do
      "in" -> from q in query, where: q.status in ^statuses
      "not" -> from q in query, where: q.status not in ^statuses
      _ -> query
    end
  end

  defp add_workorder_type_filter_to_query(query, nil), do: query
  defp add_workorder_type_filter_to_query(query, type) do
    from q in query, where: q.type == ^type
  end

  def get_equipment_with_status(status, params, prefix) do
    equipment_query(Equipment, Map.put(params, "status", status))
    |> Repo.all(prefix: prefix)
  end

  def get_equipment_ageing(equipment, site_dt, prefix) do
    date_time =
      from(as in AssetStatusTrack,
            where: as.asset_id == ^equipment.id and
                  as.asset_type == "E" and
                  as.status_changed == "BRK",
            select: as.changed_date_time)
      |> Repo.all(prefix: prefix)
      |> Enum.sort_by(&(&1), NaiveDateTime)
      |> hd()

    NaiveDateTime.diff(site_dt, date_time)
  end

  def get_mtbf_of_equipment(equipment_id, from_dt, to_dt, prefix) do
    query = asset_status_track_query(equipment_id, "E", ["BRK"], "not", from_dt, to_dt)
    hours = from(q in query, select: q.hours)
            |> Repo.all(prefix: prefix)
            |> Enum.filter(fn hr -> hr != nil end)

    breakdown_times =
      from(q in asset_status_track_query(equipment_id, "E", ["BRK"], "in", from_dt, to_dt), select: count(q.hours))
      |> Repo.one(prefix: prefix)

    case breakdown_times do
      0 ->
         0
      _ ->
          Enum.sum(hours) / length(hours)
    end
  end

  def get_mttr_of_equipment(equipment_id, from_dt, to_dt, prefix) do
    query = asset_status_track_query(equipment_id, "E", ["BRK"], "in", from_dt, to_dt)
    hours = from(q in query, select: q.hours)
            |> Repo.all(prefix: prefix)
            |> Enum.filter(fn hr -> hr != nil end)

    case length(hours) do
      0 ->
         0
      length ->
          Enum.sum(hours) / length
    end
  end

  defp asset_status_track_query(asset_id, asset_type, statuses, inclusion, from_dt, to_dt) do
    query =
      from(as in AssetStatusTrack,
            where: as.asset_id == ^asset_id and
                   as.asset_type == ^asset_type and
                   as.changed_date_time >= ^from_dt and
                   as.changed_date_time <= ^to_dt
                   )

    case inclusion do
      "in" -> from q in query, where: q.status_changed in ^statuses
      "not" -> from q in query, where: q.status_changed not in ^statuses
      _ -> query
    end
  end

  def get_schedules_for_today(site_id, date, prefix) do
    get_schedule_query_for_equipment(site_id, date) |> Repo.all(prefix: prefix)
  end

  defp get_schedule_query_for_equipment(site_id, date) do
    from(wos in WorkorderSchedule, where: wos.next_occurrence_date == ^date,
         join: e in Equipment, on: e.id == wos.asset_id and wos.asset_type == "E" and e.site_id == ^site_id,
         join: s in Site, on: s.id == e.site_id,
         join: wot in WorkorderTemplate, on: wot.id == wos.workorder_template_id and wot.repeat_unit not in ["H", "D"],
         select: %{
          schedule: wos,
          template: wot
         })
  end

end
