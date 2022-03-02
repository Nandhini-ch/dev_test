defmodule Inconn2Service.Measurements do
  @moduledoc """
  The Measurements context.
  """

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.WorkOrderConfig.Task
  alias Inconn2Service.Workorder.WorkorderTask
  alias Inconn2Service.Measurements.MeterReading

  @doc """
  Returns the list of meter_readings.

  ## Examples

      iex> list_meter_readings()
      [%MeterReading{}, ...]

  """
  def list_meter_readings(prefix) do
    Repo.all(MeterReading, prefix: prefix)
  end

  @doc """
  Gets a single meter_reading.

  Raises `Ecto.NoResultsError` if the Meter reading does not exist.

  ## Examples

      iex> get_meter_reading!(123)
      %MeterReading{}

      iex> get_meter_reading!(456)
      ** (Ecto.NoResultsError)

  """
  def get_meter_reading!(id, prefix), do: Repo.get!(MeterReading, id, prefix: prefix)

  @doc """
  Creates a meter_reading.

  ## Examples

      iex> create_meter_reading(%{field: value})
      {:ok, %MeterReading{}}

      iex> create_meter_reading(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_meter_reading(attrs \\ %{}, prefix) do
    %MeterReading{}
    |> MeterReading.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a meter_reading.

  ## Examples

      iex> update_meter_reading(meter_reading, %{field: new_value})
      {:ok, %MeterReading{}}

      iex> update_meter_reading(meter_reading, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_meter_reading(%MeterReading{} = meter_reading, attrs, prefix) do
    meter_reading
    |> MeterReading.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a meter_reading.

  ## Examples

      iex> delete_meter_reading(meter_reading)
      {:ok, %MeterReading{}}

      iex> delete_meter_reading(meter_reading)
      {:error, %Ecto.Changeset{}}

  """
  def delete_meter_reading(%MeterReading{} = meter_reading, prefix) do
    Repo.delete(meter_reading, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking meter_reading changes.

  ## Examples

      iex> change_meter_reading(meter_reading)
      %Ecto.Changeset{data: %MeterReading{}}

  """
  def change_meter_reading(%MeterReading{} = meter_reading, attrs \\ %{}) do
    MeterReading.changeset(meter_reading, attrs)
  end

  def record_meter_readings_from_work_order(work_order, prefix) do
    wot_query = from wot in WorkorderTask, where: wot.work_order_id == ^work_order.id

    from t in Task,
      join: wot in ^wot_query, on: wot.task_id == t.id, where: t.task_type == "MT",
      select: %{}




  end
end
