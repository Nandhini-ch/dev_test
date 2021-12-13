defmodule Inconn2Service.Common do
  @moduledoc """
  The Common context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Inconn2Service.Repo
  alias Inconn2Service.Common.Timezone

  @doc """
  Returns the list of timezones.

  ## Examples

      iex> list_timezones()
      [%Timezone{}, ...]

  """
  def list_timezones do
    from(t in Timezone, order_by: [asc: t.utc_offset_seconds])
    |> Repo.all()
  end

  def search_timezones(city_text) do
    if String.length(city_text) < 3 do
      []
    else
      search_text = city_text <> "%"

      from(t in Timezone, where: ilike(t.city, ^search_text), order_by: t.city)
      |> Repo.all()
    end
  end

  @doc """
  Gets a single timezone.

  Raises `Ecto.NoResultsError` if the Timezone does not exist.

  ## Examples

      iex> get_timezone!(123)
      %Timezone{}

      iex> get_timezone!(456)
      ** (Ecto.NoResultsError)

  """
  def get_timezone!(id), do: Repo.get!(Timezone, id)

  @doc """
  Creates a timezone.

  ## Examples

      iex> create_timezone(%{field: value})
      {:ok, %Timezone{}}

      iex> create_timezone(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_timezone(attrs \\ %{}) do
    %Timezone{}
    |> Timezone.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a timezone.

  ## Examples

      iex> update_timezone(timezone, %{field: new_value})
      {:ok, %Timezone{}}

      iex> update_timezone(timezone, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_timezone(%Timezone{} = timezone, attrs) do
    timezone
    |> Timezone.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a timezone.

  ## Examples

      iex> delete_timezone(timezone)
      {:ok, %Timezone{}}

      iex> delete_timezone(timezone)
      {:error, %Ecto.Changeset{}}

  """
  def delete_timezone(%Timezone{} = timezone) do
    Repo.delete(timezone)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking timezone changes.

  ## Examples

      iex> change_timezone(timezone)
      %Ecto.Changeset{data: %Timezone{}}

  """
  def change_timezone(%Timezone{} = timezone, attrs \\ %{}) do
    Timezone.changeset(timezone, attrs)
  end

  def shift_to_utc(date, time, zone) do
    {:ok, ndt} = NaiveDateTime.new(date, time)
    {:ok, dt} = DateTime.from_naive(ndt, zone)
    DateTime.shift_zone(dt, "Etc/UTC", Tzdata.TimeZoneDatabase)
  end

  def shift_to_utc(date, time, zone, before_seconds) do
    {:ok, ndt} = NaiveDateTime.new(date, time)
    {:ok, dt} = DateTime.from_naive(ndt, zone)
    DateTime.add(dt, -1 * before_seconds, :second, Tzdata.TimeZoneDatabase)
    |> DateTime.shift_zone!("Etc/UTC", Tzdata.TimeZoneDatabase)
  end

  def build_timezone_db() do
    Tzdata.canonical_zone_list()
    |> Enum.reduce([], &make_tzmap/2)
    |> Enum.map(fn entry -> create_timezone(entry) end)
  end

  defp make_tzmap(zone, tzmaplist) do
    {off_text, off_secs} = calculate_utc_offset(zone)

    case String.split(zone, "/") do
      [continent | [city]] ->
        add_tz_entry(tzmaplist, zone, continent, "", city, off_text, off_secs)

      [continent | [state | [city]]] ->
        add_tz_entry(tzmaplist, zone, continent, state, city, off_text, off_secs)

      _ ->
        tzmaplist
    end
  end

  defp add_tz_entry(tzmaplist, zone, continent, state, city, off_text, off_secs) do
    [
      %{
        continent: continent,
        label: zone,
        state: state,
        city: String.replace(city, "_", " "),
        utc_offset_text: off_text,
        utc_offset_seconds: off_secs
      }
      | tzmaplist
    ]
  end

  defp calculate_utc_offset(zone) do
    {:ok, pl} = Tzdata.periods(zone)

    [period_selected | []] =
      Enum.filter(pl, fn p -> p.until.utc == :max end)
      |> Enum.take(1)

    utc_offset = Map.get(period_selected, :utc_off)

    if utc_offset != nil do
      {make_utc_offset_string(period_selected.utc_off), utc_offset}
    else
      IO.puts("#{zone} : #{inspect(period_selected)}")
    end
  end

  defp make_utc_offset_string(seconds) do
    {sign, secs} =
      case seconds < 0 do
        true -> {"-", seconds * -1}
        false -> {"+", seconds}
      end

    m = div(secs, 60)
    hours = div(m, 60)
    mins = rem(m, 60)

    str_mins =
      case mins < 10 do
        true -> "0" <> to_string(mins)
        false -> to_string(mins)
      end

    "UTC" <> sign <> to_string(hours) <> ":" <> str_mins
  end

  alias Inconn2Service.Common.WorkScheduler
  alias Inconn2Service.Workorder.WorkorderSchedule

  def list_works_chedulers do
    Repo.all(WorkScheduler)
  end

  def get_work_scheduler!(id), do: Repo.get!(WorkScheduler, id)

  def calculate_utc_datetime(cs) do
    workorder_schedule_id = get_field(cs, :workorder_schedule_id)
    prefix = get_field(cs, :prefix)
    zone = get_field(cs, :zone)
    workorder_schedule = Repo.get!(WorkorderSchedule, workorder_schedule_id, prefix: prefix) |> Repo.preload(:workorder_template)
    before_seconds = workorder_schedule.workorder_template.workorder_prior_time * 60
    date = workorder_schedule.next_occurrence_date
    time = workorder_schedule.next_occurrence_time
    utc = shift_to_utc(date, time, zone, before_seconds)
    change(cs, %{utc_date_time: utc})
  end
  def create_work_scheduler(attrs \\ %{}) do
    %WorkScheduler{}
    |> WorkScheduler.changeset(attrs)
    |> calculate_utc_datetime
    |> Repo.insert()
  end

  def update_work_scheduler(workorder_schedule_id, attrs \\ %{}) do
    work_scheduler = Repo.get_by!(WorkScheduler, workorder_schedule_id: workorder_schedule_id)
    work_scheduler
    |> WorkScheduler.changeset(attrs)
    |> calculate_utc_datetime
    |> Repo.update()
  end

  def delete_work_scheduler(workorder_schedule_id) do
    work_scheduler = Repo.get_by(WorkScheduler, workorder_schedule_id: workorder_schedule_id)
    Repo.delete(work_scheduler)
  end

  def delete_work_scheduler_cs(workorder_schedule_id, attrs \\ %{}) do
    work_scheduler = Repo.get_by(WorkScheduler, workorder_schedule_id: workorder_schedule_id)
    if work_scheduler != nil do
      WorkScheduler.changeset(work_scheduler, attrs)
    else
      WorkScheduler.changeset(%WorkScheduler{}, attrs)
    end
  end

  def insert_work_scheduler_cs(attrs \\ %{}) do
    %WorkScheduler{}
      |> WorkScheduler.changeset(attrs)
      |> calculate_utc_datetime
  end

  def change_work_scheduler(%WorkScheduler{} = work_scheduler, attrs \\ %{}) do
    WorkScheduler.changeset(work_scheduler, attrs)
  end


  alias Inconn2Service.Common.IotMetering

  @doc """
  Returns the list of iot_meterings.

  ## Examples

      iex> list_iot_meterings()
      [%IotMetering{}, ...]

  """
  def list_iot_meterings do
    Repo.all(IotMetering)
  end

  @doc """
  Gets a single iot_metering.

  Raises `Ecto.NoResultsError` if the Iot metering does not exist.

  ## Examples

      iex> get_iot_metering!(123)
      %IotMetering{}

      iex> get_iot_metering!(456)
      ** (Ecto.NoResultsError)

  """
  def get_iot_metering!(id), do: Repo.get!(IotMetering, id)

  @doc """
  Creates a iot_metering.

  ## Examples

      iex> create_iot_metering(%{field: value})
      {:ok, %IotMetering{}}

      iex> create_iot_metering(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_iot_metering(attrs \\ %{}) do
    %IotMetering{}
    |> IotMetering.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a iot_metering.

  ## Examples

      iex> update_iot_metering(iot_metering, %{field: new_value})
      {:ok, %IotMetering{}}

      iex> update_iot_metering(iot_metering, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_iot_metering(%IotMetering{} = iot_metering, attrs) do
    iot_metering
    |> IotMetering.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a iot_metering.

  ## Examples

      iex> delete_iot_metering(iot_metering)
      {:ok, %IotMetering{}}

      iex> delete_iot_metering(iot_metering)
      {:error, %Ecto.Changeset{}}

  """
  def delete_iot_metering(%IotMetering{} = iot_metering) do
    Repo.delete(iot_metering)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking iot_metering changes.

  ## Examples

      iex> change_iot_metering(iot_metering)
      %Ecto.Changeset{data: %IotMetering{}}

  """
  def change_iot_metering(%IotMetering{} = iot_metering, attrs \\ %{}) do
    IotMetering.changeset(iot_metering, attrs)
  end

  alias Inconn2Service.Common.ListOfValue

  @doc """
  Returns the list of list_of_values.

  ## Examples

      iex> list_list_of_values()
      [%ListOfValue{}, ...]

  """
  def list_list_of_values(prefix) do
    Repo.all(ListOfValue, prefix: prefix)
  end

  @doc """
  Gets a single list_of_value.

  Raises `Ecto.NoResultsError` if the List of value does not exist.

  ## Examples

      iex> get_list_of_value!(123)
      %ListOfValue{}

      iex> get_list_of_value!(456)
      ** (Ecto.NoResultsError)

  """
  def get_list_of_value!(id, prefix), do: Repo.get!(ListOfValue, id, prefix: prefix)

  @doc """
  Creates a list_of_value.

  ## Examples

      iex> create_list_of_value(%{field: value})
      {:ok, %ListOfValue{}}

      iex> create_list_of_value(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_list_of_value(attrs \\ %{}, prefix) do
    %ListOfValue{}
    |> ListOfValue.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a list_of_value.

  ## Examples

      iex> update_list_of_value(list_of_value, %{field: new_value})
      {:ok, %ListOfValue{}}

      iex> update_list_of_value(list_of_value, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_list_of_value(%ListOfValue{} = list_of_value, attrs, prefix) do
    list_of_value
    |> ListOfValue.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a list_of_value.

  ## Examples

      iex> delete_list_of_value(list_of_value)
      {:ok, %ListOfValue{}}

      iex> delete_list_of_value(list_of_value)
      {:error, %Ecto.Changeset{}}

  """
  def delete_list_of_value(%ListOfValue{} = list_of_value, prefix) do
    Repo.delete(list_of_value, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking list_of_value changes.

  ## Examples

      iex> change_list_of_value(list_of_value)
      %Ecto.Changeset{data: %ListOfValue{}}

  """
  def change_list_of_value(%ListOfValue{} = list_of_value, attrs \\ %{}) do
    ListOfValue.changeset(list_of_value, attrs)
  end
end
