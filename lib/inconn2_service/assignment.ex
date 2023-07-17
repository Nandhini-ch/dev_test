defmodule Inconn2Service.Assignment do
  @moduledoc """
  The Assignment context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  import Inconn2Service.Util.IndexQueries
  import Inconn2Service.Util.HelpersFunctions
  import Inconn2Service.Prompt
  alias Inconn2Service.Repo

  alias Inconn2Service.Assignment.EmployeeRoster
  alias Inconn2Service.Assignment.Attendance
  alias Inconn2Service.Staff.Employee
  alias Inconn2Service.{Staff, Assignments}
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.{Site, SiteConfig}
  alias Inconn2Service.Settings
  alias Inconn2Service.Settings.Shift
  alias Inconn2Service.Assignment.ManualAttendance
  alias Inconn2Service.Assignments.{MasterRoster, Roster}
  alias Inconn2Service.Assignment.Attendance

  def list_employee_rosters(prefix) do
    EmployeeRoster
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix) |> Repo.preload([:site, :shift, employee: :org_unit])
  end

  def list_employee_rosters(user, prefix) do
    EmployeeRoster
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix) |> Repo.preload([:site, :shift, employee: :org_unit])
    |> Enum.filter(fn x -> filter_by_user_is_licensee(x, user, prefix) end)
  end

  def list_employee_roster_for_shift_and_date(%{"shift_id" => shift_id, "date" => date}, user, prefix) do
    {:ok, date} = date_convert(date)
    query =
      from(e in EmployeeRoster,
        where:
          e.shift_id == ^shift_id and
          fragment("? BETWEEN ? AND ?", ^date, e.start_date, e.end_date)
    )
    Repo.add_active_filter(query)
    |> Repo.all(prefix: prefix)
    |> Repo.preload([:site, :shift, employee: :org_unit])
    |> Enum.filter(fn x -> filter_by_user_is_licensee(x, user, prefix) end)
  end

  def list_employee_roster_for_site_and_date(%{"site_id" => site_id, "date" => date}, user, prefix) do
    {:ok, date} = date_convert(date)
    query =
      from(e in EmployeeRoster,
        where:
          e.site_id == ^site_id and
          fragment("? BETWEEN ? AND ?", ^date, e.start_date, e.end_date)
    )
    Repo.add_active_filter(query)
    |> Repo.all(prefix: prefix)
    |> Repo.preload([:site, :shift, employee: :org_unit])
    |> Enum.filter(fn x -> filter_by_user_is_licensee(x, user, prefix) end)
  end

  def list_employees_for_date_range(%{"site_id" => site_id, "from_date" => from_date, "to_date" => to_date}, user, prefix) do
    {:ok, from_date} = date_convert(from_date)
    {:ok, to_date} = date_convert(to_date)
    query =
      from(e in EmployeeRoster,
        where:
          e.site_id == ^site_id and
          fragment("? BETWEEN ? AND ?", ^from_date, e.start_date, e.end_date) or
          fragment("? BETWEEN ? AND ?", ^to_date, e.start_date, e.end_date)
    )
    Repo.add_active_filter(query)
    |> Repo.all(prefix: prefix)
    |> Repo.preload([employee: :org_unit])
    |> Enum.filter(fn x -> filter_by_user_is_licensee(x, user, prefix) end)
    |> Enum.map(fn employee_roster -> employee_roster.employee end)
    |> Enum.uniq()
  end

  def list_employee_for_attendance(query_params, user, prefix) do
    {:ok, date} = date_convert(query_params["date"])
    query =
      from(e in EmployeeRoster,
        where:
          e.shift_id == ^query_params["shift_id"] and
          fragment("? BETWEEN ? AND ?", ^date, e.start_date, e.end_date)
      )
    Repo.all(query, prefix: prefix)
    |> Repo.preload([employee: :org_unit])
    |> Enum.filter(fn x -> filter_by_user_is_licensee(x, user, prefix) end)
    |> Enum.map(fn employee_roster -> employee_roster.employee end)
  end

  def list_manual_employee_for_attendance(query_params, user, prefix) do
    date = get_site_date(query_params["site_id"], prefix)
    user = user |> Repo.preload(:employee)
    manual_attendance_employee_ids = get_manual_attendance_employees(query_params["shift_id"], prefix)
    case user.employee do
      nil ->
        []

      _ ->
            from(er in EmployeeRoster,
                where: er.shift_id == ^query_params["shift_id"] and
                        fragment("? BETWEEN ? AND ?", ^date, er.start_date, er.end_date),
                join: e in Employee, on: er.employee_id == e.id, where: e.id not in ^manual_attendance_employee_ids and (e.reports_to == ^user.employee.id or e.org_unit_id == ^user.employee.org_unit_id),
                select: e
            )
            |> Repo.all(prefix: prefix)
    end
  end

  defp get_manual_attendance_employees(shift_id, prefix) do
    {start_time, end_time} = convert_shift_times_to_datetimes(shift_id, prefix)
    from(ma in ManualAttendance,
         where: ma.shift_id == ^shift_id and
                fragment("? BETWEEN ? AND ?", ma.in_time, ^start_time, ^end_time),
    )
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn x -> x.employee_id end)
  end

  def list_sites_from_roster(user, prefix) do
    user = user |> Repo.preload(:employee)
    case user.employee do
      nil ->
        []

      _ ->
            from(er in EmployeeRoster,
                where: er.employee_id == ^user.employee.id,
                join: s in Site, on: er.site_id == s.id,
                select: s
            )
            |> Repo.all(prefix: prefix)
            |> Enum.uniq()
    end
  end

  def list_sites_for_employee(nil, _prefix), do: []
  def list_sites_for_employee(employee, prefix) do
    from(er in EmployeeRoster,
        where: er.employee_id == ^employee.id,
        join: s in Site, on: er.site_id == s.id,
        select: s
    )
    |> Repo.all(prefix: prefix)
    |> Enum.uniq()
  end

  defp convert_shift_times_to_datetimes(shift_id, prefix) do
    shift = Settings.get_shift!(shift_id, prefix)
    date = get_site_date(shift.site_id, prefix)
    {NaiveDateTime.new!(date, shift.start_time), NaiveDateTime.new!(date, shift.end_time)}
  end

  defp get_site_date(site_id, prefix) do
    site = AssetConfig.get_site!(site_id, prefix)
    DateTime.now!(site.time_zone) |> DateTime.to_date()
  end

  defp filter_by_user_is_licensee(emp_roster, user, prefix) do
    case (AssetConfig.get_party!(user.party_id, prefix)).licensee do
      false ->
              user.party_id == emp_roster.employee.party_id
      true ->
              true
    end
  end

  defp date_convert(date_to_convert) do
    date_to_convert
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
    |> (fn [year, month, day] -> Date.new(year, month, day) end).()
  end

  def get_employee_roster!(id, prefix), do: Repo.get!(EmployeeRoster, id, prefix: prefix) |> Repo.preload([:site, :shift, employee: :org_unit])

  def create_employee_roster(attrs \\ %{}, prefix) do
    result = %EmployeeRoster{}
      |> EmployeeRoster.changeset(attrs)
      |> validate_employee_id(prefix)
      |> validate_shift_id(prefix)
      |> auto_fill_site_id(prefix)
      |> validate_within_shift_dates(prefix)
      |> Repo.insert(prefix: prefix)
    case result do
      {:ok, employee_roster} -> {:ok, employee_roster |> Repo.preload([:site, :shift, employee: :org_unit])}
      _ -> result
    end
  end

  def auto_fill_site_id(cs, prefix) do
    shift_id = get_change(cs, :shift_id, nil)
    if shift_id != nil do
      shift = Settings.get_shift(shift_id, prefix)
      case shift do
        nil -> cs
        _ -> change(cs, %{site_id: shift.site_id})
      end
    else
      cs
    end
  end

  defp validate_employee_id(cs, prefix) do
    emp_id = get_change(cs, :employee_id, nil)
    if emp_id != nil do
      case Repo.get(Employee, emp_id, prefix: prefix) do
        nil -> add_error(cs, :employee_id, "Employee ID is invalid")
        _ -> cs
      end
    else
      cs
    end
  end

  defp validate_shift_id(cs, prefix) do
    shift_id = get_change(cs, :shift_id, nil)
    if shift_id != nil do
      case Repo.get(Shift, shift_id, prefix: prefix) do
        nil -> add_error(cs, :shift_id, "Shift ID is invalid")
        _ -> cs
      end
    else
      cs
    end
  end

  defp validate_within_shift_dates(cs, prefix) do
    roster_start = get_field(cs, :start_date)
    roster_end = get_field(cs, :end_date)
    shift_id = get_field(cs, :shift_id)
    if shift_id != nil and roster_start != nil and roster_end != nil do
      shift = Repo.get(Shift, shift_id, prefix: prefix)
      if shift != nil do
        case Date.compare(roster_start, shift.start_date) do
          :lt ->
              add_error(cs, :start_date, "cannot be earlier than start date of shift")
          _ ->
              case Date.compare(roster_end, shift.end_date) do
                :gt -> add_error(cs, :end_date, "cannot be later than end date of shift")
                _ -> cs
              end
        end
      else
        cs
      end
    else
      cs
    end
  end

  def update_employee_roster(%EmployeeRoster{} = employee_roster, attrs, prefix) do
    result =
      employee_roster
    |> EmployeeRoster.changeset(attrs)
    |> validate_employee_id(prefix)
    |> validate_shift_id(prefix)
    |> auto_fill_site_id(prefix)
    |> validate_within_shift_dates(prefix)
    |> Repo.update(prefix: prefix)

    case result do
      {:ok, employee_roster} -> {:ok, employee_roster |> Repo.preload([:site, :shift, employee: :org_unit], force: true)}
      _ -> result
    end
  end

  def delete_employee_roster(%EmployeeRoster{} = employee_roster, prefix) do
    update_employee_roster(employee_roster, %{"active" => false}, prefix)
       {:deleted,
         "The employee roster was disabled"
       }
  end

  def change_employee_roster(%EmployeeRoster{} = employee_roster, attrs \\ %{}) do
    EmployeeRoster.changeset(employee_roster, attrs)
  end

  def list_attendances(query_params, prefix) do
    query_params = get_date_time_for_query(query_params, prefix)
    from(a in Attendance)
    |> attendance_query(query_params)
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn attendance -> preload_employee(attendance, prefix) end)
    |> Stream.map(fn attendance -> preload_shift(attendance, prefix) end)
    |> Enum.sort_by(&(&1.in_time), NaiveDateTime)
  end

  # def list_attendances_for_user(_query_params, user, _prefix) when is_nil(user.employee_id), do: []
  # def list_attendances_for_user(query_params, user, prefix) when not is_nil(user.employee_id) do
  #   Map.put(query_params, "employee_id", user.employee_id)
  #   |> list_attendances_for_employee(prefix)
  # end

  def list_attendances_for_employee(user, _from_date, _to_date, _prefix) when is_nil(user.employee_id), do: []
  def list_attendances_for_employee(user, from_date, to_date, prefix) do
    # query_params = Map.put(query_params, "employee_id", user.employee_id)
    modify_from_date = NaiveDateTime.new!(from_date, ~T[00:00:00])
    modify_to_date = NaiveDateTime.new!(to_date, ~T[23:59:59])
    from(r in Roster, where: r.employee_id == ^user.employee_id,
      left_join: a in Attendance, on: a.roster_id == r.id, where: a.in_time >= ^modify_from_date and r.in_time <= ^modify_to_date,
      select: %{
        id: a.id,
        latitude: a.latitude,
        longitude: a.longitude,
        site_id: a.site_id,
        in_time: a.in_time,
        out_time: a.out_time,
        status: a.status,
        roster_id: r.id,
        date: r.date,
        employee_id: r.employee_id,
        shift_id: r.shift_id,
        master_roster_id: r.master_roster_id
      }
    )
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn attendance ->
      if is_nil(attendance.in_time) do
        Map.put(attendance, :status, "ASNT")
      else
        attendance
      end
    end)
    |> Stream.map(fn attendance -> preload_employee(attendance, prefix) end)
    |> Enum.map(fn attendance -> preload_shift(attendance, prefix) end)
    # |> Enum.sort_by(&(&1.in_time), NaiveDateTime)
  end

  def list_attendances_for_team(team_id, prefix) do
    employee_ids = Staff.get_employee_ids_of_team(team_id, prefix)
    list_attendances(%{"employee_ids" => employee_ids}, prefix)
  end

  def list_attendance_for_mandatory_employee(begin_schedule_date_time, end_schedule_date_time, employee_id, site_id, prefix) do
    query =
      from a in Attendance,
        where: a.in_time >= ^begin_schedule_date_time and a.in_time <= ^end_schedule_date_time and
               a.employee_id == ^employee_id and a.site_id == ^site_id

    query
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn attendance -> preload_shift(attendance, prefix) end)
  end

  defp preload_employee(attendance, prefix) do
    employee = Repo.get!(Employee, attendance.employee_id, prefix: prefix)
    Map.put(attendance, :employee, employee)
  end

  defp preload_shift(attendance, _prefix) when is_nil(attendance.shift_id) do
    Map.put(attendance, :shift, nil)
  end

  defp preload_shift(attendance, prefix) when not is_nil(attendance.shift_id) do
    shift = Settings.get_shift!(attendance.shift_id, prefix)
    Map.put(attendance, :shift, shift)
  end

  defp get_date_time_for_query(query_params, _prefix) do
    if query_params["from_date"] != nil and query_params["to_date"] != nil do
      {from_date, to_date} = {NaiveDateTime.from_iso8601!(query_params["from_date"] <> " 00:00:00"), NaiveDateTime.from_iso8601!(query_params["to_date"] <> " 23:59:59")}
      Map.put(query_params, "from_date", from_date)
      |> Map.put("to_date", to_date)
    else
      # site = AssetConfig.get_site!(query_params["site_id"], prefix)
      # date = DateTime.now!(site.time_zone) |> DateTime.to_date()
      # {from_date, to_date} = {NaiveDateTime.new!(date, Time.new!(0, 0, 0)), NaiveDateTime.new!(date, Time.new!(23, 59, 59))}
      # Map.put(query_params, "from_date", from_date)
      # |> Map.put("to_date", to_date)
      query_params
    end
  end

  def get_attendance!(id, prefix), do: Repo.get!(Attendance, id, prefix: prefix) |> preload_employee(prefix)

  defp get_previous_partial_attendance(site_id, employee_id, prefix) do
    from(a in Attendance,
          where: not is_nil(a.in_time) and
                a.site_id == ^site_id and
                a.employee_id == ^employee_id and
                is_nil(a.out_time),
                order_by: a.id, limit: 1)
    |> Repo.one(prefix: prefix)
  end

  def mark_facial_attendance(_attrs, _, user, _prefix) when is_nil(user.employee_id) do
    {:error, "Employee doesnot exist"}
  end

  def mark_facial_attendance(attrs, "out", user, prefix) do
    case get_previous_partial_attendance(attrs["site_id"], user.employee_id, prefix) do
      nil ->
        {:error, "Intime should be marked first"}

      attendance ->
        update_attendance(attendance, %{"out_time" => attrs["date_time"]}, prefix)
    end
  end

  def mark_facial_attendance(attrs, "in", user, prefix) do
    case get_previous_partial_attendance(attrs["site_id"], user.employee_id, prefix) do
      nil ->
        Map.put(attrs, "employee_id", user.employee_id)
        |> Map.put("in_time", attrs["date_time"])
        |> create_attendance(prefix)

      _attendance ->
        {:error, "Already marked intime"}
    end
  end

  def create_attendance(attrs \\ %{}, prefix) do
    result = %Attendance{}
            |> Attendance.changeset(attrs)
            |> match_roster_and_fill_shift_id(prefix)
            |> Repo.insert(prefix: prefix)
    case result do
      {:ok, attendance} ->
              {:ok,
              preload_employee(attendance, prefix) |> preload_shift(prefix)
            }
      _ ->
          result
    end
  end

  def get_rosters_for_attendance(employee_id, site_id, date, prefix) do
    from(r in Roster, where: r.employee_id == ^ employee_id and r.date == ^date,
    join: mr in MasterRoster, on: mr.id == r.master_roster_id, where: mr.site_id == ^site_id,
    join: s in Shift, on: s.id == r.shift_id,
    select: %{roster_id: r.id,
    shift_id: s.id,
    shift_start: s.start_time,
    shift_end: s.end_time
    })
    |> Repo.all(prefix: prefix)
  end

  defp match_roster_and_fill_shift_id(cs, prefix) do
    employee_id = get_field(cs, :employee_id)
    site_id = get_field(cs, :site_id)
    in_dt = get_field(cs, :in_time)
    site_config =
      case AssetConfig.get_site_config_by_site_id_and_type(site_id, "ATT", prefix) do
        nil -> %{config: %{}}
        config -> config
      end
    grace_period = Map.get(site_config.config, "grace_period_in_minutes", 0)
    cond do
      employee_id && site_id && in_dt ->
        roster_with_shift = get_rosters_for_attendance(employee_id, site_id, NaiveDateTime.to_date(in_dt), prefix)

        altered_roster_with_shift =
          Enum.map(roster_with_shift, fn x ->
            shift_start = x.shift_start
            altered_time = Time.add(shift_start, -grace_period * 60)
            Map.put(x, :shift_start, altered_time)
          end)

        filtered_roster_with_shift =
          Enum.filter(altered_roster_with_shift, fn x ->
            altered_time = Map.get(x, :shift_start)
            end_time = Map.get(x, :shift_end)
            in_time = NaiveDateTime.to_time(in_dt)

            altered_time >= in_time && in_time <= end_time
          end)

          map = List.first(filtered_roster_with_shift, %{roster_id: nil, shift_id: nil})

          change(cs, %{roster_id: map.roster_id, shift_id: map.shift_id})

    true ->
        cs
    end
  end

  defp get_matching_shift__id_for_attendance([], _in_time), do: nil
  defp get_matching_shift__id_for_attendance(matching_shifts, in_time) do
    {shift_id, _time_diff} =
      matching_shifts
      |> Stream.map(fn shift ->
          {
            shift.id,
            Time.diff(in_time, shift.start_time) |> convert_integer_to_non_neg_integer()
          }
        end)
      |> Enum.min_by(fn {_shift_id, time_diff} -> time_diff end)
    shift_id
  end

  defp get_employee_current_user(cs, user, prefix) do
    employee = Staff.get_employee_email!(user.username, prefix)
    case employee do
      nil -> add_error(cs, :employee_id, "Employee doesnot exist")
      _ -> change(cs, %{employee_id: employee.id})
    end
  end

  def update_attendance(%Attendance{} = attendance, attrs, prefix) do
    result =
      attendance
      |> Attendance.changeset(attrs)
      |> Repo.update(prefix: prefix)

    case result do
      {:ok, attendance} ->
           {:ok, attendance} = calculate_and_update_attendance_status(attendance, prefix)
              {:ok,
              preload_employee(attendance, prefix) |> preload_shift(prefix)
            }
      _ ->
          result
    end
  end

  defp calculate_and_update_attendance_status(attendance, prefix) when not is_nil(attendance.shift_id) and not is_nil(attendance.in_time) and not is_nil(attendance.out_time) do
    site_config =
      case AssetConfig.get_site_config_by_site_id_and_type(attendance.site_id, "ATT", prefix) do
        nil -> %{config: %{}}
        config -> config
      end
    shift = Settings.get_shift!(attendance.shift_id, prefix)
    grace_period = Map.get(site_config.config, "grace_period_in_minutes", 0)
    half_day_hours = Map.get(site_config.config, "half_day_work_hours", 0)
    worked_hours = NaiveDateTime.diff(attendance.in_time, attendance.out_time) * 3600

    status =
      case NaiveDateTime.compare(attendance.in_time, NaiveDateTime.add(shift.start_time, grace_period, :minute)) do
        :gt -> "LATE"
        _ -> "ONTM"
      end

    status =
      if worked_hours < half_day_hours do
        "HFDY"
      else
        status
      end

    attendance
    |> Attendance.changeset(%{"status" => status})
    |> Repo.update(prefix: prefix)

  end

  defp calculate_and_update_attendance_status(attendance, _prefix) do
    {:ok, attendance}
  end

  def delete_attendance(%Attendance{} = attendance, prefix) do
    Repo.delete(attendance, prefix: prefix)
  end

  def change_attendance(%Attendance{} = attendance, attrs \\ %{}) do
    Attendance.changeset(attendance, attrs)
  end

  alias Inconn2Service.Assignment.AttendanceReference

  def list_attendance_references(prefix) do
    Repo.all(AttendanceReference, prefix: prefix)
  end

  def get_attendance_reference_for_employee(query_params, prefix) do
    from(ar in AttendanceReference, where: ar.employee_id == ^query_params["employee_id"])
    |> Repo.all(prefix: prefix)
  end

  def get_attendance_reference!(id, prefix), do: Repo.get!(AttendanceReference, id, prefix: prefix)

  def create_attendance_reference(attrs \\ %{}, prefix, user) do
    # employee_id = get_employee_current_user(user.username, prefix).id
    %AttendanceReference{}
    |> AttendanceReference.changeset(attrs)
    |> get_employee_current_user(user, prefix)
    |> Repo.insert(prefix: prefix)
  end

  def update_attendance_reference(%AttendanceReference{} = attendance_reference, attrs, prefix) do
    attendance_reference
    |> AttendanceReference.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_attendance_reference(%AttendanceReference{} = attendance_reference, prefix) do
    Repo.delete(attendance_reference, prefix: prefix)
  end

  def change_attendance_reference(%AttendanceReference{} = attendance_reference, attrs \\ %{}) do
    AttendanceReference.changeset(attendance_reference, attrs)
  end

  alias Inconn2Service.Assignment.AttendanceFailureLog

  def list_attendance_failure_logs(query_params, prefix) do
    query = from afl in AttendanceFailureLog
    query = Enum.reduce(query_params, query, fn
              {"employee_id", employee_id}, query ->
                from q in query, where: q.employee_id == ^employee_id

              _ , query ->
                query
            end)
    Repo.all(query, prefix: prefix)
  end

  def get_attendance_failure_log!(id, prefix), do: Repo.get!(AttendanceFailureLog, id, prefix: prefix)

  def create_attendance_failure_log(attrs \\ %{}, prefix, user) do
    # employee_id = get_employee_current_user(user.username, prefix).id
    %AttendanceFailureLog{}
    |> AttendanceFailureLog.changeset(attrs)
    |> get_employee_current_user(user, prefix)
    |> Repo.insert(prefix: prefix)
  end

  def update_attendance_failure_log(%AttendanceFailureLog{} = attendance_failure_log, attrs, prefix) do
    attendance_failure_log
    |> AttendanceFailureLog.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_attendance_failure_log(%AttendanceFailureLog{} = attendance_failure_log, prefix) do
    Repo.delete(attendance_failure_log, prefix: prefix)
  end

  def change_attendance_failure_log(%AttendanceFailureLog{} = attendance_failure_log, attrs \\ %{}) do
    AttendanceFailureLog.changeset(attendance_failure_log, attrs)
  end

  def list_manual_attendances(prefix) do
    Repo.all(ManualAttendance, prefix: prefix)
    |> Enum.map(fn attendance -> preload_employee(attendance, prefix) end)
  end

  def list_manual_attendances(query_params, prefix) do
    date = get_site_date(query_params["site_id"], prefix)
    start_time = NaiveDateTime.new!(date, Time.new!(00, 00, 00))
    end_time = NaiveDateTime.new!(date, Time.new!(23, 59, 59))
    from(ma in ManualAttendance,
          where: ma.shift_id == ^query_params["shift_id"] and (fragment("? BETWEEN ? AND ?", ma.in_time, ^start_time, ^end_time) or is_nil(ma.out_time)),
          )
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn attendance -> preload_employee(attendance, prefix) end)
  end

  def get_manual_attendance!(id, prefix), do: Repo.get!(ManualAttendance, id, prefix: prefix) |> preload_employee(prefix)

  def create_manual_attendance(attrs \\ %{}, prefix, user \\ %{}) do
    result = %ManualAttendance{}
              |> ManualAttendance.changeset(attrs)
              |> validate_in_time_in_shift(prefix)
              |> record_user(user)
              |> Repo.insert(prefix: prefix)
    case result do
      {:ok, manual_attendance} ->
          {:ok, manual_attendance} = calculate_and_update_attendance(manual_attendance, prefix)
          {:ok, manual_attendance |> preload_employee(prefix)}
      _ ->
        result
    end
  end

  defp validate_in_time_in_shift(cs, prefix) do
    shift_id = get_field(cs, :shift_id)
    in_time = get_change(cs, :in_time)
    if shift_id != nil and in_time != nil do
      {start_time, end_time} = convert_shift_times_to_datetimes(shift_id, prefix)
      case in_time >= start_time and in_time <= end_time do
        true -> cs
        false -> add_error(cs, :in_time, "Not within shift timing")
      end
    else
      cs
    end
  end

  defp record_user(cs, user) do
    in_time = get_change(cs, :in_time)
    out_time = get_change(cs, :out_time)
    cs = if in_time != nil, do: in_time_marked_by(cs, user.id), else: cs
    if out_time != nil, do: out_time_marked_by(cs, user.id), else: cs
  end

  defp in_time_marked_by(cs, user_id), do: change(cs, %{in_time_marked_by: user_id})

  defp out_time_marked_by(cs, user_id), do: change(cs, %{out_time_marked_by: user_id})

  defp calculate_and_update_attendance(manual_attendance, prefix) do
    attendance_config = get_attendance_site_config_from_shift(manual_attendance.shift_id, prefix)
    {worked_hrs, overtime_hrs} = calculate_worked_and_overtime_hrs(manual_attendance, attendance_config)
    status = calculate_attendance_status(manual_attendance, worked_hrs, attendance_config, prefix)
    attrs =
            %{
              "worked_hours_in_minutes" => worked_hrs,
              "overtime_hours_in_minutes" => overtime_hrs,
              "status" => status
            }
    manual_attendance
    |> ManualAttendance.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  defp calculate_worked_and_overtime_hrs(manual_attendance, attendance_config) when not is_nil(manual_attendance.out_time) do
    worked_hrs = Time.diff(manual_attendance.out_time, manual_attendance.in_time) / 60
    case manual_attendance.is_overtime do
      false ->
        {worked_hrs, 0}
      true ->
        overtime_hrs = worked_hrs - attendance_config.config["preferred_total_work_hours"]
        if overtime_hrs < 0 do
          {worked_hrs, 0}
        else
          {attendance_config.config["preferred_total_work_hours"], overtime_hrs}
        end
    end
  end

  defp calculate_worked_and_overtime_hrs(_manual_attendance, _attendance_config), do: {nil, nil}

  defp calculate_attendance_status(_manual_attendance, nil, _attendance_config, _prefix), do: nil

  defp calculate_attendance_status(manual_attendance, worked_hrs, attendance_config, prefix) do
    shift = Settings.get_shift!(manual_attendance.shift_id, prefix)
    cond do
      worked_hrs <= attendance_config.config["half_day_work_hours"] ->
        "AB"

      (Time.diff(manual_attendance.in_time, shift.start_time) / 60) > attendance_config.config["grace_period_in_minutes"] ->
        "LT"

      true ->
        "PT"
    end
  end

  defp get_attendance_site_config_from_shift(shift_id, prefix) do
    from(sh in Shift, where: sh.id == ^shift_id,
         join: si in Site, on: si.id == sh.site_id,
         join: sc in SiteConfig, on: sc.site_id == si.id, where: sc.type == "ATT",
         select: sc
    )
    |> Repo.one(prefix: prefix)
  end

  def update_manual_attendance(%ManualAttendance{} = manual_attendance, attrs, prefix, user \\ %{}) do
    result = manual_attendance
              |> ManualAttendance.changeset(attrs)
              |> validate_in_time_in_shift(prefix)
              |> record_user(user)
              |> Repo.update(prefix: prefix)
    case result do
      {:ok, manual_attendance} ->
          {:ok, manual_attendance} = calculate_and_update_attendance(manual_attendance, prefix)
          {:ok, manual_attendance |> preload_employee(prefix)}
      _ ->
        result
    end
  end

  def delete_manual_attendance(%ManualAttendance{} = manual_attendance, prefix) do
    Repo.delete(manual_attendance, prefix: prefix)
  end

  def change_manual_attendance(%ManualAttendance{} = manual_attendance, attrs \\ %{}) do
    ManualAttendance.changeset(manual_attendance, attrs)
  end

  # def push_alert_notification_for_new_roster(site_id, prefix) do
  #   generate_alert_notification("NRSAD", site_id, ["shift_name"], [], [], prefix)
  # end
end
