defmodule Inconn2Service.Dashboards.NumericalData do
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Measurements.MeterReading
  alias Inconn2Service.Workorder.WorkOrder
  # alias Inconn2Service.AssetConfig.AssetCategory
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

  def get_workorder_for_chart(site_id, from_date, to_date, asset_category_ids, nil, _asset_type, prefix) do
    query = get_workorder_general_query(site_id, from_date, to_date)
    from(q in query, join: wot in WorkorderTemplate, on: q.workorder_template_id == wot.id,
                     join: ac in AssetCategory, on: ac.id == wot.asset_category_id and wot.asset_category_id in ^asset_category_ids,
                     select: %{
                      asset_category_id: ac.id,
                      work_orders: q
                     })
    |> Repo.all(prefix: prefix)
  end

  def get_workorder_for_chart(site_id, from_date, to_date, nil, asset_ids, asset_type, prefix) do
    query = get_workorder_general_query(site_id, from_date, to_date)
    from(q in query, where: q.asset_id in ^asset_ids and q.asset_type == ^asset_type,
                     select: %{
                      asset_id: q.asset_id,
                      work_orders: q
                     })

    |> Repo.all(prefix: prefix)
  end

  def progressing_workorders(site_id, from_date, to_date) do
    add_status_filter_to_query(get_workorder_general_query(site_id, from_date, to_date), ["cp", "cn"], "not")
  end

  def in_progress_workorders(site_id, from_date, to_date) do
    add_status_filter_to_query(get_workorder_general_query(site_id, from_date, to_date), ["ip"], "in")
  end

  def get_open_tickets(site_id, from_datetime, to_datetime) do
    add_status_filter_to_query(get_work_request_general_query(site_id, from_datetime, to_datetime), ["CP", "CS"], "not")
  end

  def get_close_tickets(site_id, from_datetime, to_datetime) do
    add_status_filter_to_query(get_work_request_general_query(site_id, from_datetime, to_datetime), ["cp"], "in")
  end

  def get_open_ticket_chart(site_id, from_datetime, to_datetime, ticket_category_ids) do
    query = get_open_tickets(site_id, from_datetime, to_datetime)
    from(q in query, where: q.workrequest_category_id in ^ticket_category_ids)
  end

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
    end
  end


end
