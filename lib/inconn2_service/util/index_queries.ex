defmodule Inconn2Service.Util.IndexQueries do
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Util.HierarchyManager
  alias Inconn2Service.AssetConfig
  # alias Inconn2Service.Assignment.EmployeeRoster
  # alias Inconn2Service.Settings.Shift
  #alias Inconn2Service.InventoryManagement.Store

  def site_query(query, query_params, prefix) do
    Enum.reduce(query_params, query, fn
      {"zone_id", zone_id}, query ->
          zone_ids = get_subtree_zone_ids(zone_id, prefix)
          from q in query, where: q.zone_id in ^zone_ids

      _, query -> query
    end)
  end

  def employee_rosters_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
    _, query -> query end)
  end

  def shift_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
    _, query -> query end)
  end

  def store_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
    _, query -> query end)
  end

  def equipment_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
    _, query -> query end)
  end

  def location_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
    _, query -> query end)
  end

  defp get_subtree_zone_ids(zone_id, prefix) do
    subtree_query = AssetConfig.get_zone!(zone_id, prefix)
                    |> HierarchyManager.subtree()

    from(q in subtree_query, select: q.id)
    |> Repo.all(prefix: prefix)
  end
end
