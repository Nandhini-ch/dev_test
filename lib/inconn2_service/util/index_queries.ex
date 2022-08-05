defmodule Inconn2Service.Util.IndexQueries do
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Util.HierarchyManager
  alias Inconn2Service.AssetConfig
  # alias Inconn2Service.Assignment.EmployeeRoster
  # alias Inconn2Service.Settings.Shift
  #alias Inconn2Service.InventoryManagement.Store
  #alias Inconn2Service.AssetConfig.{Site, Zone}
  #alias Inconn2Service.AssetConfig.Party

  def site_query(query, query_params, prefix) do
    Enum.reduce(query_params, query, fn
      {"zone_id", zone_id}, query ->
          zone_ids = get_subtree_zone_ids(zone_id, prefix)
          from q in query, where: q.zone_id in ^zone_ids
      {"party_id", party_id}, query -> from q in query, where: q.party_id == ^party_id
      _, query -> query
    end)
  end

  def employee_rosters_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
      _, query -> query
    end)
  end

  def shift_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
      _, query -> query
    end)
  end

  def store_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
      _, query -> query
    end)
  end

  def equipment_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
    {"asset_category_id", asset_category_id}, query -> from q in query, where: q.asset_category_id == ^asset_category_id
    {"asset_category_ids", asset_category_ids}, query -> from q in query, where: q.asset_category_id in ^asset_category_ids
    {"location_id", location_id}, query -> from q in query, where: q.location_id == ^location_id
    _, query -> query
    end)
  end

  def location_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
      {"asset_category_id", asset_category_id}, query -> from q in query, where: q.asset_category_id == ^asset_category_id
      _, query -> query
    end)
  end

  def check_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"check_type_id", check_type_id}, query -> from q in query, where: q.check_type_id == ^check_type_id
      _, query -> query
    end)
  end

  def workorder_template_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"asset_category_id", asset_category_id}, query -> from q in query, where: q.asset_category_id == ^asset_category_id
    {"workpermit_check_list_id", workpermit_check_list_id}, query -> from q in query, where: q.workpermit_check_list_id == ^workpermit_check_list_id
    {"loto_lock_check_list_id", loto_lock_check_list_id}, query -> from q in query, where: q.loto_lock_check_list_id == ^loto_lock_check_list_id
    {"loto_release_check_list_id", loto_release_check_list_id}, query -> from q in query, where: q.loto_release_check_list_id == ^loto_release_check_list_id
    _, query -> query end)
  end

  def workorder_schedule_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"asset_id", asset_id}, query -> from q in query, where: q.asset_id == ^asset_id
      {"asset_type", asset_type}, query -> from q in query, where: q.asset_type == ^asset_type
      _, query -> query end)
  end

  def task_list_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"asset_category_id", asset_category_id}, query -> from q in query, where: q.asset_category_id == ^asset_category_id
      _, query -> query end)
  end

  def contract_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"party_id", party_id}, query ->from q in query, where: q.party_id == ^party_id
      _, query -> query end)
  end

  def scope_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
    {"contract_id", contract_id}, query -> from q in query, where: q.contract_id == ^contract_id
    _, query -> query end)
  end

  defp get_subtree_zone_ids(zone_id, prefix) do
    subtree_query = AssetConfig.get_zone!(zone_id, prefix)
                    |> HierarchyManager.subtree()

    from(q in subtree_query, select: q.id)
    |> Repo.all(prefix: prefix)
  end

  def org_unit_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"party_id", party_id}, query -> from q in query, where: q.party_id == ^party_id
      _, query -> query
    end)
  end

  def employee_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"party_id", party_id}, query -> from q in query, where: q.party_id == ^party_id
      _, query -> query
    end)
  end

  def user_query(query, query_params) do
    Enum.reduce(query_params, query, fn
      {"party_id", party_id}, query -> from q in query, where: q.party_id == ^party_id
      _, query -> query
    end)
  end
end
