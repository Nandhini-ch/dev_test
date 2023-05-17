defmodule Inconn2Service.Dashboards.NumericalData do
  import Ecto.Query, warn: false
  import Inconn2Service.Util.IndexQueries
  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.IotService.ApiCalls
  alias Inconn2Service.Repo

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Measurements.MeterReading
  alias Inconn2Service.AssetConfig.{Location, Equipment, Site}
  alias Inconn2Service.Workorder.WorkorderTemplate
  alias Inconn2Service.Workorder.{WorkOrder, WorkorderSchedule}
  alias Inconn2Service.AssetConfig.{AssetCategory, Equipment, AssetStatusTrack}
  alias Inconn2Service.Ticket.WorkRequest
  alias Inconn2Service.Assignment.Attendance
  alias Inconn2Service.Assignments.{MasterRoster, Roster}
  alias Inconn2Service.Settings.Shift
  alias Inconn2Service.Staff.Employee
  alias Inconn2Service.InventoryManagement.{SiteStock, InventoryItem}


  def get_energy_consumption_for_assets(nil, _from_dt, _to_dt, _prefix), do: 0
  def get_energy_consumption_for_assets(assets, from_dt, to_dt, prefix) do
    cond do
      Enum.all?(assets, &(is_integer(&1))) ->
        query = from mr in MeterReading,
                  where: mr.asset_id in ^assets and
                        mr.asset_type == "E" and
                        mr.unit_of_measurement == "Kwh" and
                        mr.meter_type == "E" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
        Repo.one(query, prefix: prefix)

      Enum.all?(assets, &(is_map(&1))) ->
        get_energy_consumption_for_assets_with_iot(assets, from_dt, to_dt, prefix)
        |> Enum.reject(&is_nil/1)
        |> Enum.sum()

      true ->
        0
    end
  end

  def get_energy_consumption_for_assets_with_iot(assets, from_dt, to_dt, prefix) do
    Enum.map(assets, fn asset_map ->
      if asset_map["iot"] do
        get_energy_consumption_of_iot_asset(asset_map["id"], from_dt, to_dt, prefix)
      else
        query = from mr in MeterReading,
                  where: mr.asset_id == ^asset_map["id"] and
                        mr.asset_type == "E" and
                        mr.meter_type == "E" and
                        mr.unit_of_measurement == "Kwh" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
        Repo.one(query, prefix: prefix)
      end
    end)
  end

  def get_water_consumption_for_assets(nil, _from_dt, _to_dt, _prefix), do: 0
  def get_water_consumption_for_assets(asset_ids, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.asset_id in ^asset_ids and
                        mr.asset_type == "E" and
                        mr.meter_type == "W" and
                        mr.unit_of_measurement == "KL" and
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
                        mr.unit_of_measurement == "KL" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_energy_consumption_for_asset(asset, from_dt, to_dt, prefix) when is_integer(asset) do
    query = from mr in MeterReading,
                  where: mr.asset_id == ^asset and
                        mr.asset_type == "E" and
                        mr.meter_type == "E" and
                        mr.unit_of_measurement == "Kwh" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_energy_consumption_for_asset(asset, from_dt, to_dt, prefix) when is_map(asset) do
    if asset["iot"] do
      get_energy_consumption_of_iot_asset(asset["id"], from_dt, to_dt, prefix)
    else
      query = from mr in MeterReading,
                where: mr.asset_id == ^asset["id"] and
                      mr.asset_type == "E" and
                      mr.meter_type == "E" and
                      mr.unit_of_measurement == "Kwh" and
                      mr.recorded_date_time >= ^from_dt and
                      mr.recorded_date_time <= ^to_dt,
                select: sum(mr.absolute_value)
      Repo.one(query, prefix: prefix)
    end
  end

  def get_water_consumption_for_asset(asset_id, from_dt, to_dt, prefix) do
    query = from mr in MeterReading,
                  where: mr.asset_id == ^asset_id and
                        mr.asset_type == "E" and
                        mr.meter_type == "W" and
                        mr.unit_of_measurement == "KL" and
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
                        mr.unit_of_measurement == "KL" and
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
                        mr.unit_of_measurement == "Kwh" and
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
                        mr.unit_of_measurement == "Kwh" and
                        mr.recorded_date_time >= ^from_dt and
                        mr.recorded_date_time <= ^to_dt,
                  select: sum(mr.absolute_value)
    Repo.one(query, prefix: prefix)
  end

  def get_work_order_numerical_cost(site_id, prefix) do
    date = get_site_date_now(site_id, prefix) |> Date.add(-1)
    from(wo in WorkOrder, where: wo.scheduled_date == ^date and wo.status == "cp")
    |> Repo.all(prefix: prefix)
  end

  def get_work_order_cost(params, prefix) do
    query = from(wo in WorkOrder, where: wo.site_id == ^params["site_id"] and wo.status == "cp")
    dynamic_query = work_order_cost_query(query, params)
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"], params["site_id"], prefix)
    from(dq in dynamic_query, where: dq.scheduled_date >= ^from_date and dq.scheduled_date <= ^to_date)
    |> Repo.all(prefix: prefix)
  end

  defp work_order_cost_query(query, params) do
    Enum.reduce(params, query, fn
      {"asset_ids", asset_ids}, query ->
        from(q in query, where: q.asset_id in ^asset_ids and q.asset_type == ^params["asset_type"] )
      {"asset_category_ids", asset_category_ids}, query ->
        from(q in query, join: wot in WorkorderTemplate, on: q.workorder_template_id == wot.id and wot.asset_category_id in ^asset_category_ids)
      _, query ->
        query
    end)
  end

  def get_for_workorder_count(site_id, from_date, to_date, prefix) do
    get_workorder_general_query(site_id, from_date, to_date) |> Repo.all(prefix: prefix)
  end

  def get_workorder_chart_data_for_site_asset_category(site_id, from_date, to_date, type, criticality, prefix) do
    from(ac in AssetCategory,
         left_join: wot in WorkorderTemplate, on: wot.asset_category_id == ac.id,
         left_join: wo in WorkOrder, on: wo.workorder_template_id == wot.id and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date and wo.site_id == ^site_id and wo.type in ^type and wo.status != "cn",
         select: %{
          asset_category_id: ac.id,
          asset_category_name: ac.name,
          work_order: wo
         })
    |> Repo.all(prefix: prefix)
    |> Enum.map(&(add_criticality_to_workorder_data(&1, prefix)))
    |> filter_workorder_data_by_criticality(criticality)
  end

  def get_workorder_chart_data_for_site_asset(site_id, from_date, to_date, asset_type, type, criticality, prefix) do
    asset_query = get_asset_query_for_site(site_id, asset_type)
    from(from a in asset_query,
          left_join: wo in WorkOrder, on: wo.asset_id == a.id and wo.asset_type == ^asset_type and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date and wo.site_id == ^site_id and wo.type in ^type and wo.status != "cn",
          select: %{
            asset_id: a.id,
            asset_name: a.name,
            criticality: a.criticality,
            work_order: wo
          })
    |> Repo.all(prefix: prefix)
    |> filter_workorder_data_by_criticality(criticality)
  end

  def get_workorder_chart_data_for_asset_categories(site_id, from_date, to_date, asset_category_ids, type, criticality, prefix) do
    from(ac in AssetCategory, where: ac.id in ^asset_category_ids,
         left_join: wot in WorkorderTemplate, on: wot.asset_category_id == ac.id,
         left_join: wo in WorkOrder, on: wo.workorder_template_id == wot.id and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date and wo.site_id == ^site_id and wo.type in ^type and wo.status != "cn",
         select: %{
          asset_category_id: ac.id,
          asset_category_name: ac.name,
          work_order: wo
         })
    |> Repo.all(prefix: prefix)
    |> Enum.map(&(add_criticality_to_workorder_data(&1, prefix)))
    |> filter_workorder_data_by_criticality(criticality)
  end

  def get_workorder_chart_data_for_assets(site_id, from_date, to_date, asset_ids, asset_type, type, criticality, prefix) do
    asset_query = get_asset_query(asset_ids, asset_type)
    from(from a in asset_query,
          left_join: wo in WorkOrder, on: wo.asset_id == a.id and wo.asset_type == ^asset_type and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date and wo.site_id == ^site_id and wo.type in ^type and wo.status != "cn",
          select: %{
            asset_id: a.id,
            asset_name: a.name,
            criticality: a.criticality,
            work_order: wo
          })
    |> Repo.all(prefix: prefix)
    |> filter_workorder_data_by_criticality(criticality)
  end

  def get_service_breakdown_workorder_chart_data_for_site_asset_category(site_id, from_date, to_date, :service_wo, criticality, prefix) do
    from(ac in AssetCategory,
         left_join: wot in WorkorderTemplate, on: wot.asset_category_id == ac.id and wot.adhoc,
         left_join: wo in WorkOrder, on: wo.workorder_template_id == wot.id and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date and wo.site_id == ^site_id and wo.status != "cn",
         select: %{
          asset_category_id: ac.id,
          asset_category_name: ac.name,
          work_order: wo
         })
    |> Repo.all(prefix: prefix)
    |> Enum.map(&(add_criticality_to_workorder_data(&1, prefix)))
    |> filter_workorder_data_by_criticality(criticality)
  end

  def get_service_breakdown_workorder_chart_data_for_site_asset_category(site_id, from_date, to_date, :breakdown_wo, criticality, prefix) do
    from(ac in AssetCategory,
         left_join: wot in WorkorderTemplate, on: wot.asset_category_id == ac.id and wot.breakdown,
         left_join: wo in WorkOrder, on: wo.workorder_template_id == wot.id and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date and wo.site_id == ^site_id and wo.status != "cn",
         select: %{
          asset_category_id: ac.id,
          asset_category_name: ac.name,
          work_order: wo
         })
    |> Repo.all(prefix: prefix)
    |> Enum.map(&(add_criticality_to_workorder_data(&1, prefix)))
    |> filter_workorder_data_by_criticality(criticality)
  end

  def get_service_breakdown_workorder_chart_data_for_site_asset(site_id, from_date, to_date, asset_type, :service_wo, criticality, prefix) do
    asset_query = get_asset_query_for_site(site_id, asset_type)
    from(from a in asset_query,
          left_join: wo in WorkOrder, on: wo.asset_id == a.id and wo.asset_type == ^asset_type and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date and wo.site_id == ^site_id and wo.status != "cn",
          join: wot in WorkorderTemplate, where: wot.adhoc,
          select: %{
            asset_id: a.id,
            asset_name: a.name,
            criticality: a.criticality,
            work_order: wo
          })
    |> Repo.all(prefix: prefix)
    |> filter_workorder_data_by_criticality(criticality)
  end

  def get_service_breakdown_workorder_chart_data_for_site_asset(site_id, from_date, to_date, asset_type, :breakdown_wo, criticality, prefix) do
    asset_query = get_asset_query_for_site(site_id, asset_type)
    from(from a in asset_query,
          left_join: wo in WorkOrder, on: wo.asset_id == a.id and wo.asset_type == ^asset_type and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date and wo.site_id == ^site_id and wo.status != "cn",
          join: wot in WorkorderTemplate, where: wot.breakdown,
          select: %{
            asset_id: a.id,
            asset_name: a.name,
            criticality: a.criticality,
            work_order: wo
          })
    |> Repo.all(prefix: prefix)
    |> filter_workorder_data_by_criticality(criticality)
  end

  def get_service_breakdown_workorder_chart_data_for_asset_categories(site_id, from_date, to_date, asset_category_ids, :service_wo, criticality, prefix) do
    from(ac in AssetCategory, where: ac.id in ^asset_category_ids,
         left_join: wot in WorkorderTemplate, on: wot.asset_category_id == ac.id and wot.adhoc,
         left_join: wo in WorkOrder, on: wo.workorder_template_id == wot.id and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date and wo.site_id == ^site_id and wo.status != "cn",
         select: %{
          asset_category_id: ac.id,
          asset_category_name: ac.name,
          work_order: wo
         })
    |> Repo.all(prefix: prefix)
    |> Enum.map(&(add_criticality_to_workorder_data(&1, prefix)))
    |> filter_workorder_data_by_criticality(criticality)
  end

  def get_service_breakdown_workorder_chart_data_for_asset_categories(site_id, from_date, to_date, asset_category_ids, :breakdown_wo, criticality, prefix) do
    from(ac in AssetCategory, where: ac.id in ^asset_category_ids,
         left_join: wot in WorkorderTemplate, on: wot.asset_category_id == ac.id and wot.breakdown,
         left_join: wo in WorkOrder, on: wo.workorder_template_id == wot.id and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date and wo.site_id == ^site_id and wo.status != "cn",
         select: %{
          asset_category_id: ac.id,
          asset_category_name: ac.name,
          work_order: wo
         })
    |> Repo.all(prefix: prefix)
    |> Enum.map(&(add_criticality_to_workorder_data(&1, prefix)))
    |> filter_workorder_data_by_criticality(criticality)
  end

  def get_service_breakdown_workorder_chart_data_for_assets(site_id, from_date, to_date, asset_ids, asset_type, :service_wo, criticality, prefix) do
    asset_query = get_asset_query(asset_ids, asset_type)
    from(from a in asset_query,
          left_join: wo in WorkOrder, on: wo.asset_id == a.id and wo.asset_type == ^asset_type and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date and wo.site_id == ^site_id and wo.status != "cn",
          join: wot in WorkorderTemplate, where: wot.adhoc,
          select: %{
            asset_id: a.id,
            asset_name: a.name,
            criticality: a.criticality,
            work_order: wo
          })
    |> Repo.all(prefix: prefix)
    |> filter_workorder_data_by_criticality(criticality)
  end

  def get_service_breakdown_workorder_chart_data_for_assets(site_id, from_date, to_date, asset_ids, asset_type, :breakdown_wo, criticality, prefix) do
    asset_query = get_asset_query(asset_ids, asset_type)
    from(from a in asset_query,
          left_join: wo in WorkOrder, on: wo.asset_id == a.id and wo.asset_type == ^asset_type and wo.scheduled_date >= ^from_date and wo.scheduled_date <= ^to_date and wo.site_id == ^site_id and wo.status != "cn",
          join: wot in WorkorderTemplate, where: wot.breakdown,
          select: %{
            asset_id: a.id,
            asset_name: a.name,
            criticality: a.criticality,
            work_order: wo
          })
    |> Repo.all(prefix: prefix)
    |> filter_workorder_data_by_criticality(criticality)
  end

  def add_criticality_to_workorder_data(data, prefix) when not is_nil(data.work_order) do
      Map.put(
        data,
        :criticality,
        AssetConfig.get_asset_by_type(data.work_order.asset_id, data.work_order.asset_type, prefix).criticality
        )
  end
  def add_criticality_to_workorder_data(data, _prefix), do:  Map.put(data, :criticality, nil)

  def filter_workorder_data_by_criticality(data_list, nil), do: data_list
  def filter_workorder_data_by_criticality(data_list, 0), do: data_list
  def filter_workorder_data_by_criticality(data_list, criticality) do
    Enum.filter(data_list, fn data -> data.criticality == criticality end)
  end

  def get_workorder_for_chart(site_id, from_date, to_date, type, prefix) do
    get_workorder_general_query(site_id, from_date, to_date)
    |> add_status_filter_to_query(["cn"], "not")
    |> add_workorder_type_filter_to_query(type)
    |> Repo.all(prefix: prefix)
  end

  def get_service_workorder_for_chart(site_id, from_date, to_date, prefix) do
    wo_query = get_workorder_general_query(site_id, from_date, to_date)
    from(q in wo_query,
      join: wot in WorkorderTemplate, on: wot.id == wo.workorder_template_id, where: wot.adhoc)
    |> add_status_filter_to_query(["cn"], "not")
    |> Repo.all(prefix: prefix)
  end

  def get_breakdown_workorder_for_chart(site_id, from_date, to_date, prefix) do
    wo_query = get_workorder_general_query(site_id, from_date, to_date)
    from(q in wo_query,
      join: wot in WorkorderTemplate, on: wot.id == wo.workorder_template_id, where: wot.breakdown)
    |> add_status_filter_to_query(["cn"], "not")
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

  defp get_asset_query(asset_ids, "L"), do: from l in Location, where: l.id in ^asset_ids
  defp get_asset_query(asset_ids, "E"), do: from e in Equipment, where: e.id in ^asset_ids
  defp get_asset_query_for_site(site_id, "L"), do: from l in Location, where: l.site_id == ^site_id
  defp get_asset_query_for_site(site_id, "E"), do: from e in Equipment, where: e.site_id == ^site_id

  defp add_workorder_type_filter_to_query(query, nil), do: query
  defp add_workorder_type_filter_to_query(query, type) do
    from q in query, where: q.type == ^type
  end

  def get_equipment_with_status(status, params, prefix) do
    ids = AssetConfig.get_asset_category_subtree_ids(params["asset_category_id"], prefix)
    params =
      params
      |> Map.put("status", status)
      |> Map.put("asset_category_ids", ids)
      |> Map.drop(["asset_category_id"])

    equipment_query(Equipment, params)
    |> Repo.all(prefix: prefix)
  end

  def get_equipment_ageing(equipment, site_dt, prefix) do
    date_time_list =
      from(as in AssetStatusTrack,
            where: as.asset_id == ^equipment.id and
                  as.asset_type == "E" and
                  as.status_changed == "BRK",
            select: as.changed_date_time)
      |> Repo.all(prefix: prefix)
      |> Enum.sort_by(&(&1), NaiveDateTime)

    get_equipment_ageing_from_date_list(date_time_list, site_dt)
  end

  defp get_equipment_ageing_from_date_list([], _site_dt), do: 0
  defp get_equipment_ageing_from_date_list([date_time | _], site_dt), do: NaiveDateTime.diff(site_dt, date_time)

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
          Enum.sum(hours) / breakdown_times
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
         select: wos)
  end

  def get_expected_rosters(site_id, from_date, to_date, prefix) do
    from(mr in MasterRoster, where: mr.site_id == ^site_id,
      join: r in Roster, on: r.master_roster_id == mr.id, where: r.date >= ^from_date and r.date <= ^to_date,
      join: sh in Shift, on: sh.id == r.shift_id,
      select: %{
        site_id: mr.site_id,
        employee_id: r.employee_id,
        roster_date: r.date,
        shift_id: r.shift_id,
        shift_start: sh.start_time
      }
    )
    |> Repo.all(prefix: prefix)
  end

  def get_attendances(site_id, from_dt, to_dt, prefix) do
    from(a in Attendance, where: a.site_id == ^site_id and a.in_time >= ^from_dt and a.in_time <= ^to_dt,
      join: sh in Shift, on: sh.id == a.shift_id,
      select: %{
        in_time: a.in_time,
        out_time: a.out_time,
        site_id: a.site_id,
        employee_id: a.employee_id,
        shift_id: a.shift_id,
        shift_start: sh.start_time
      })
    |> Repo.all(prefix: prefix)
  end

  def get_expected_rosters(site_id, org_unit_id, shift_id, from_date, to_date, prefix) do
    from(mr in MasterRoster, where: mr.site_id == ^site_id,
      join: r in Roster, on: r.master_roster_id == mr.id, where: r.shift_id == ^shift_id and r.date >= ^from_date and r.date <= ^to_date,
      join: e in Employee, on: e.id == r.employee_id, where: e.org_unit_id == ^org_unit_id,
      join: sh in Shift, on: sh.id == r.shift_id,
      select: %{
        site_id: mr.site_id,
        employee_id: r.employee_id,
        roster_date: r.date,
        shift_id: r.shift_id,
        shift_start: sh.start_time
      }
    )
    |> Repo.all(prefix: prefix)
  end

  def get_attendances(site_id, org_unit_id, shift_id, from_dt, to_dt, prefix) do
    from(a in Attendance, where: a.site_id == ^site_id and a.shift_id == ^shift_id and a.in_time >= ^from_dt and a.in_time <= ^to_dt,
      join: e in Employee, on: e.id == a.employee_id, where: e.org_unit_id == ^org_unit_id,
      join: sh in Shift, on: sh.id == a.shift_id,
      select: %{
        in_time: a.in_time,
        out_time: a.out_time,
        site_id: a.site_id,
        employee_id: a.employee_id,
        shift_id: a.shift_id,
        shift_start: sh.start_time
      })
    |> Repo.all(prefix: prefix)
  end

  def breached_items_count_for_site(site_id, prefix) do
    from(s in SiteStock, where: s.is_msl_breached == "YES" and s.site_id == ^site_id)
    |> Repo.all(prefix: prefix)
    |> Enum.count()
  end

  def get_number_of_days_breached(params, prefix) do
    from(i in InventoryItem, where: ^params["asset_category_id"] in i.asset_category_ids,
        join: s in SiteStock, on: s.inventory_item_id == i.id and s.site_id == ^params["site_id"], select: s)
        |> Repo.all(prefix: prefix)
  end

  def get_energy_consumption_of_iot_asset(asset_id, from_dt, to_dt, prefix) do
    ApiCalls.get_energy_consumption_for_asset(asset_id, "E", from_dt, to_dt, prefix)
  end
end
