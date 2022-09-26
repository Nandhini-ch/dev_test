defmodule Inconn2Service.Assignments do
  @moduledoc """
  The Assignments context.
  """

  import Ecto.Query, warn: false
  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Repo
  alias Inconn2Service.{Staff, Settings}
  alias Inconn2Service.Assignments.{MasterRoster, Roster}

  def get_master_roster(params, prefix) do
    {from_date, to_date} = get_from_date_to_date_from_iso(params["from_date"], params["to_date"])

    {:ok, master_roster} = check_and_create_master_roster(params, prefix)

    master_roster
    |> Repo.preload(:site)
    |> Repo.preload(:designation)
    |> preload_rosters(from_date, to_date, prefix)
  end

  defp preload_rosters(nil, _from_date, _to_date, _prefix), do: nil
  defp preload_rosters(master_roster, from_date, to_date, prefix) do
    Map.put(
      master_roster,
      :rosters,
      get_rosters(master_roster.id, from_date, to_date, prefix)
    )
  end

  def get_master_roster_without_preloads(site_id, designation_id, prefix) do
    MasterRoster
    |> where([site_id: ^site_id, designation_id: ^designation_id])
    |> Repo.one(prefix: prefix)
  end

  def create_or_update_master_rosters(attrs, prefix) do
    {:ok, master_roster} = check_and_create_master_roster(attrs, prefix)
    check_and_create_rosters(master_roster.id, attrs["assignment"], prefix)
    get_master_roster(attrs, prefix)
  end

  def check_and_create_master_roster(attrs, prefix) do
    case master_roster = get_master_roster_without_preloads(attrs["site_id"], attrs["designation_id"], prefix) do
      nil ->
        create_master_roster(attrs, prefix)

      _ ->
        {:ok, master_roster}

    end
  end

  defp check_and_create_rosters(master_roster_id, new_attrs_list, prefix) do
    # {from_date, to_date} = get_date_range_from_attrs_dates(new_attrs_list)
    # existing_list = get_rosters_by_master_roster_and_dates(master_roster_id, from_date, to_date, prefix)
    existing_list = get_rosters_by_master_roster_id(master_roster_id, prefix)
    new_attrs_list =
      Enum.map(new_attrs_list, fn attrs ->
        Map.put(attrs, "master_roster_id", master_roster_id)
      end)
    manipulate_and_create_rosters({new_attrs_list, existing_list, []}, prefix)
  end

  defp manipulate_and_create_rosters({[], existing_list, to_insert_list}, prefix) do
    to_insert_list
    |> Enum.map(&Task.async(fn -> create_roster(&1, prefix) end))
    |> Enum.map(&Task.await/1)

    existing_list
    |> Enum.map(&Task.async(fn -> delete_roster(&1, prefix) end))
    |> Enum.map(&Task.await/1)
  end

  defp manipulate_and_create_rosters({[attrs | remaining_attrs], existing_list, to_insert_list}, prefix) do
    existing_roster = Enum.filter(existing_list, &(match_attrs_and_struct_roster(attrs, &1)))
    if length(existing_roster) == 1 do
      manipulate_and_create_rosters({remaining_attrs, existing_list -- existing_roster, to_insert_list}, prefix)
    else
      manipulate_and_create_rosters({remaining_attrs, existing_list, [attrs | to_insert_list]}, prefix)
    end
  end

  defp get_date_range_from_attrs_dates(attrs_list) do
    date_list =
          Stream.map(attrs_list, &(Date.from_iso8601!(&1["date"])))
          |> Enum.sort(Date)
    {List.first(date_list), List.last(date_list)}
  end

  defp match_attrs_and_struct_roster(attrs, struct) do
      struct.shift_id == attrs["shift_id"] and
      struct.employee_id == attrs["employee_id"] and
      struct.date == attrs["date"]
  end

  def create_master_roster(attrs \\ %{}, prefix) do
    %MasterRoster{}
    |> MasterRoster.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def get_rosters(master_roster_id, nil, nil, prefix) do
    Roster
    |> where([master_roster_id: ^master_roster_id])
    |> Repo.all(prefix: prefix)
    |> Stream.map(&(preload_employee(&1, prefix)))
    |> Enum.map(&(preload_shift(&1, prefix)))
  end

  def get_rosters(master_roster_id, from_date, to_date, prefix) do
    rosters =
      from(r in Roster,
       where: r.master_roster_id == ^master_roster_id and
              r.date >= ^from_date and
              r.date <= ^to_date)
      |> Repo.all(prefix: prefix)
      |> Stream.map(&(preload_employee(&1, prefix)))
      |> Enum.map(&(preload_shift(&1, prefix)))

    form_date_list(from_date, to_date)
    |> fill_rosters_with_empty_maps(rosters)
  end

  defp fill_rosters_with_empty_maps(date_list, rosters) do
    roster_date_list = Enum.map(rosters, &(&1.date)) |> Enum.uniq()
    Enum.reduce(date_list, rosters, fn date, acc ->
      if date in roster_date_list do
        acc
      else
        empty_map = %{
          date: date,
          id: nil,
          shift_id: nil,
          shift_name: nil,
          shift_code: nil,
          employee_id: nil,
          employee_first_name: nil,
          employee_last_name: nil
        }
        [empty_map | acc]
      end
    end)
  end

  defp preload_employee(roster, prefix) do
    employee = Staff.get_employee_without_preloads!(roster.employee_id, prefix)
    Map.merge(roster, %{employee_first_name: employee.first_name, employee_last_name: employee.last_name})
  end

  defp preload_shift(roster, prefix) do
    shift = Settings.get_shift!(roster.shift_id, prefix)
    Map.merge(roster, %{shift_name: shift.name, shift_code: shift.code})
  end

  def get_rosters_by_master_roster_id(master_roster_id, prefix) do
    Roster
    |> where([master_roster_id: ^master_roster_id])
    |> Repo.all(prefix: prefix)
  end

  def get_rosters_by_master_roster_and_dates(master_roster_id, from_date, to_date, prefix) do
    from(r in Roster,
     where: r.master_roster_id == ^master_roster_id and
            r.date >= ^from_date and
            r.date <= ^to_date)
    |> Repo.all(prefix: prefix)
  end

  def create_roster(attrs \\ %{}, prefix) do
    %Roster{}
    |> Roster.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def delete_roster(%Roster{} = roster, prefix) do
    Repo.delete(roster, prefix: prefix)
  end

  def list_sites_for_attendance(user, _prefix) when is_nil(user.employee_id), do: []

  def list_sites_for_attendance(user, prefix) do

    from(r in Roster, where: r.employee_id == ^user.employee_id,
      join: mr in MasterRoster, on: mr.id == r.master_roster_id,
      join: s in Site, on: s.id == mr.site_id,
      select: s)
   |> Repo.all(prefix: prefix)
  end

end
