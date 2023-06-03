defmodule Inconn2Service.SlaCalculation do
  import Ecto.Query, warn: false

  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Ticket.WorkRequest
  alias Inconn2Service.Workorder.WorkOrder
  alias Inconn2Service.Repo
  alias Inconn2Service.Workorder.WorkorderTemplate
  alias Inconn2Service.ContractManagement


  def get_scope_details_from_contract(contract_id, prefix) do
    initial_map = %{site_ids: [], location_ids: [], asset_category_ids: []}

    scopes = ContractManagement.list_scopes_by_contract_id(contract_id, prefix)

    final_map = Enum.reduce(scopes, initial_map, fn scope, acc -> Map.put(acc, :site_ids, [scope.site_id] ++ acc.site_ids)  end)

    final_map = Enum.reduce(scopes, final_map, fn scope, acc -> Map.put(acc, :location_ids, scope.location_ids ++ acc.location_ids)  end)

    Enum.reduce(scopes, final_map, fn scope, acc -> Map.put(acc, :asset_category_ids, scope.asset_category_ids ++ acc.asset_category_ids)  end)
  end


  def work_order_general_query(scope_map, from_date, to_date, _prefix) do
    from(wt in WorkorderTemplate, where: wt.asset_category_id in ^scope_map.asset_category_ids,
    join: wo in WorkOrder, on: wo.site_id in ^scope_map.site_ids and ^from_date <= wo.scheduled_end_date and ^to_date >= wo.scheduled_end_date,
    select: %{
               workorder_template: wt,
               work_order: wo
             }
    )
  end

  # 3 Movement completion in time %
  def movement_completion_in_time(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)
    wo_list =
      from(wt in WorkorderTemplate, where: wt.asset_category_id in ^scope_map.asset_category_ids and wt.movable,
      join: wo in WorkOrder, on: wo.site_id in ^scope_map.site_ids and ^from_date <= wo.scheduled_end_date and ^to_date >= wo.scheduled_end_date,
      select: wo
      )
      |> Repo.all(prefix: prefix)

    completed_in_time =
      Enum.count(wo_list, fn wo ->
        NaiveDateTime.compare(
          NaiveDateTime.new!(wo.completed_date, wo.completed_time),
          NaiveDateTime.new!(wo.scheduled_end_date, wo.scheduled_end_time)
        ) != :gt
      end)


    calculate_percentage(completed_in_time, Enum.count(wo_list))

  end
  # 4 Movement completion %
  def movement_completion(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)

    wo_list =
      from(wt in WorkorderTemplate, where: wt.asset_category_id in ^scope_map.asset_category_ids and wt.movable,
      join: wo in WorkOrder, on: wo.site_id in ^scope_map.site_ids and ^from_date <= wo.scheduled_end_date and ^to_date >= wo.scheduled_end_date,
      select: wo
      )
      |> Repo.all(prefix: prefix)

    completed_movable_work_order =
      Enum.count(wo_list, fn wo -> wo.status in "cp" end)

    calculate_percentage(completed_movable_work_order, Enum.count(wo_list))
  end

  # 5 Planned VS Completed
  def planned_vs_completed(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)

    wo_list =
      from(wt in WorkorderTemplate, where: wt.asset_category_id in ^scope_map.asset_category_ids,
      join: wo in WorkOrder, on: wo.site_id in ^scope_map.site_ids and ^from_date <= wo.scheduled_end_date and ^to_date >= wo.scheduled_end_date,
      select: wo
      )
      |> Repo.all(prefix: prefix)

    completed_in_work_order =
      Enum.0(wo_list, fn wo -> wo.status in "cp" end)

    calculate_percentage(completed_in_work_order, Enum.count(wo_list))
  end

  # 6 on time completion
  def on_time_completion(contract_id, from_date, to_date, prefix) do
    scope_map = get_scope_details_from_contract(contract_id, prefix)

    wo_list =
      from(wt in WorkorderTemplate, where: wt.asset_catefory_id in ^scope_map.asset_category_ids,
      join: wo in WorkOrder, on: wo.site_id in ^scope_map.site_ids and ^from_date <= wo.scheduled_end_date and ^to_date >= wo.scheduled_end_date,
      select: wo
      )
      |> Repo.all(prefix: prefix)

    completed_within_due_time =
      Enum.count(wo_list, fn wo ->
       NaiveDateTime.compare(
          NaiveDateTime.new!(wo.completed_date, wo.completed_time),
          NaiveDateTime.new!(wo.scheduled_end_date, wo.scheduled_end_time)
        ) != :gt
      end)

    calculate_percentage(completed_within_due_time, Enum.count(wo_list))
  end

  # 17 Completion %
  # def ticket_completion(contract_id, from_date, to_date, prefix) do
  #   scope_map = get_scope_details_from_contract(contract_id, prefix)

  #   total_count =


  # end
end
