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
    query = from wot in WorkorderTask,
              join: t in Task, on: t.id == wot.task_id,
              where: wot.work_order_id == ^work_order.id and t.task_type == "MT",
              select: %{
                        recorded_value: wot.response["answers"],
                        recorded_type: t.config["type"],
                        recorded_date_time: wot.actual_end_time,
                        unit_of_measurement: t.config["UOM"]
                        }

     workorder_tasks = Repo.all(query, prefix: prefix)

     Enum.map(workorder_tasks, fn workorder_task -> insert_metering_values(work_order, workorder_task, prefix) end)

  end

  def insert_metering_values(work_order, workorder_task, prefix) do
    uom = String.downcase(workorder_task.unit_of_measurement)

    query = from mr in MeterReading,
              where: [asset_id: ^work_order.asset_id,
                      asset_type: ^work_order.asset_type,
                      unit_of_measurement: ^uom],
              order_by: [desc: :recorded_date_time],
              limit: 1

    previous_reading = Repo.one(query, prefix: prefix)

    case workorder_task.recorded_type do
      "A" ->
          calculate_and_insert_cumulative_value(work_order, previous_reading, workorder_task, prefix)
      "C" ->
          calculate_and_insert_absolute_value(work_order, previous_reading, workorder_task, prefix)
    end
  end

  defp calculate_and_insert_cumulative_value(work_order, previous_reading, workorder_task, prefix) do
    cumulative_value =
          if previous_reading != nil do
            previous_reading.cumulative_value + workorder_task.recorded_value
          else
            workorder_task.recorded_value
          end
    %{
      "site_id" => work_order.site_id,
      "asset_id" => work_order.asset_id,
      "asset_type" => work_order.asset_type,
      "recorded_date_time" => workorder_task.recorded_date_time,
      "absolute_value" => workorder_task.recorded_value,
      "cumulative_value" => cumulative_value,
      "unit_of_measurement" => String.downcase(workorder_task.unit_of_measurement),
      "work_order_id" => work_order.id
    }
    |> create_meter_reading(prefix)
  end

  defp calculate_and_insert_absolute_value(work_order, previous_reading, workorder_task, prefix) do
    absolute_value =
          if previous_reading != nil do
            workorder_task.recorded_value - previous_reading.cumulative_value
          else
            workorder_task.recorded_value
          end
    %{
      "site_id" => work_order.site_id,
      "asset_id" => work_order.asset_id,
      "asset_type" => work_order.asset_type,
      "recorded_date_time" => workorder_task.recorded_date_time,
      "absolute_value" => absolute_value,
      "cumulative_value" => workorder_task.recorded_value,
      "unit_of_measurement" => String.downcase(workorder_task.unit_of_measurement),
      "work_order_id" => work_order.id
    }
    |> create_meter_reading(prefix)
  end

end
