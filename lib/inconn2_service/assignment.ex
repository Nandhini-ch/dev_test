defmodule Inconn2Service.Assignment do
  @moduledoc """
  The Assignment context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Inconn2Service.Repo

  alias Inconn2Service.Assignment.EmployeeRoster
  alias Inconn2Service.Staff.Employee
  alias Inconn2Service.AssetConfig.Site
  alias Inconn2Service.Settings.Shift

  @doc """
  Returns the list of employee_rosters.

  ## Examples

      iex> list_employee_rosters()
      [%EmployeeRoster{}, ...]

  """
  def list_employee_rosters(prefix) do
    Repo.all(EmployeeRoster,prefix: prefix)
  end

  def list_employee_rosters(query_params, prefix) do
    EmployeeRoster
    |> Repo.add_active_filter(query_params)
    |> Repo.all(prefix: prefix)
  end

  def list_employee_from_roster(query_params, prefix) do
    {:ok, date} = date_convert(query_params["date"])
    query =
      from(e in EmployeeRoster,
        where:
          e.shift_id == ^query_params["shift_id"] and
          fragment("? BETWEEN ? AND ?", ^date, e.start_date, e.end_date)
      )
    Repo.all(query, prefix: prefix)
    |> Repo.preload(:employee)
    |> Enum.map(fn employee_roster -> employee_roster.employee end)
  end

  defp date_convert(date_to_convert) do
    date_to_convert
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
    |> (fn [year, month, day] -> Date.new(year, month, day) end).()
  end

  @doc """
  Gets a single employee_roster.

  Raises `Ecto.NoResultsError` if the Employee roster does not exist.

  ## Examples

      iex> get_employee_roster!(123)
      %EmployeeRoster{}

      iex> get_employee_roster!(456)
      ** (Ecto.NoResultsError)

  """
  def get_employee_roster!(id, prefix), do: Repo.get!(EmployeeRoster, id, prefix: prefix)

  @doc """
  Creates a employee_roster.

  ## Examples

      iex> create_employee_roster(%{field: value})
      {:ok, %EmployeeRoster{}}

      iex> create_employee_roster(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_employee_roster(attrs \\ %{}, prefix) do
    %EmployeeRoster{}
    |> EmployeeRoster.changeset(attrs)
    |> validate_employee_id(prefix)
    |> validate_site_id(prefix)
    |> validate_shift_id(prefix)
    |> validate_within_shift_dates(prefix)
    |> Repo.insert(prefix: prefix)
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

  defp validate_site_id(cs, prefix) do
    site_id = get_change(cs, :site_id, nil)
    if site_id != nil do
      case Repo.get(Site, site_id, prefix: prefix) do
        nil -> add_error(cs, :site_id, "Site Id is invalid")
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
  @doc """
  Updates a employee_roster.

  ## Examples

      iex> update_employee_roster(employee_roster, %{field: new_value})
      {:ok, %EmployeeRoster{}}

      iex> update_employee_roster(employee_roster, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_employee_roster(%EmployeeRoster{} = employee_roster, attrs, prefix) do
    employee_roster
    |> EmployeeRoster.changeset(attrs)
    |> validate_employee_id(prefix)
    |> validate_site_id(prefix)
    |> validate_shift_id(prefix)
    |> validate_within_shift_dates(prefix)
    |> Repo.update(prefix: prefix)
  end

  def update_active_status_for_employee_roster(%EmployeeRoster{} = employee_roster, attrs, prefix) do
    employee_roster
    |> EmployeeRoster.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a employee_roster.

  ## Examples

      iex> delete_employee_roster(employee_roster)
      {:ok, %EmployeeRoster{}}

      iex> delete_employee_roster(employee_roster)
      {:error, %Ecto.Changeset{}}

  """
  def delete_employee_roster(%EmployeeRoster{} = employee_roster, prefix) do
    Repo.delete(employee_roster, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking employee_roster changes.

  ## Examples

      iex> change_employee_roster(employee_roster)
      %Ecto.Changeset{data: %EmployeeRoster{}}

  """
  def change_employee_roster(%EmployeeRoster{} = employee_roster, attrs \\ %{}) do
    EmployeeRoster.changeset(employee_roster, attrs)
  end

  alias Inconn2Service.Assignment.Attendance

  @doc """
  Returns the list of attendances.

  ## Examples

      iex> list_attendances()
      [%Attendance{}, ...]

  """
  def list_attendances(query_params, prefix) do
    {:ok, date} = date_convert(query_params["date"])
    query =
      from(a in Attendance,
        where:
          a.shift_id == ^query_params["shift_id"] and
          a.date == ^date
      )
    Repo.all(query, prefix: prefix)
  end

  @doc """
  Gets a single attendance.

  Raises `Ecto.NoResultsError` if the Attendance does not exist.

  ## Examples

      iex> get_attendance!(123)
      %Attendance{}

      iex> get_attendance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_attendance!(id, prefix), do: Repo.get!(Attendance, id, prefix: prefix)

  @doc """
  Creates a attendance.

  ## Examples

      iex> create_attendance(%{field: value})
      {:ok, %Attendance{}}

      iex> create_attendance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_attendance(attrs \\ %{}, prefix) do
    %Attendance{}
    |> Attendance.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a attendance.

  ## Examples

      iex> update_attendance(attendance, %{field: new_value})
      {:ok, %Attendance{}}

      iex> update_attendance(attendance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_attendance(%Attendance{} = attendance, attrs, prefix) do
    attendance
    |> Attendance.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a attendance.

  ## Examples

      iex> delete_attendance(attendance)
      {:ok, %Attendance{}}

      iex> delete_attendance(attendance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_attendance(%Attendance{} = attendance, prefix) do
    Repo.delete(attendance, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking attendance changes.

  ## Examples

      iex> change_attendance(attendance)
      %Ecto.Changeset{data: %Attendance{}}

  """
  def change_attendance(%Attendance{} = attendance, attrs \\ %{}) do
    Attendance.changeset(attendance, attrs)
  end
end
