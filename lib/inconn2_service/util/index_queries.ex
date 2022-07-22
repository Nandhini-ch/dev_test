defmodule Inconn2Service.Util.IndexQueries do
  import Ecto.Query, warn: false
  # alias Inconn2Service.Assignment.EmployeeRoster
  # alias Inconn2Service.Settings.Shift
  #alias Inconn2Service.InventoryManagement.Store
  #alias Inconn2Service.AssetConfig.{Equipment, Location}


  def employee_rosters_query(query, %{}), do: query

  def employee_rosters_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
    _, query -> query end)
  end

  def shift_query(query, %{}), do: query

  def shift_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
    _, query -> query end)
  end


  def store_query(query, %{}), do: query

  def store_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
    _, query -> query end)
  end


  def equipment_query(query, %{}), do: query

  def equipment_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
    _, query -> query end)
  end

  def location_query(query, %{}), do: query

  def location_query(query, query_params) do
    Enum.reduce(query_params, query, fn
    {"site_id", site_id}, query -> from q in query, where: q.site_id == ^site_id
    _, query -> query end)
  end


end
