defmodule Inconn2Service.Measurements do
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.WorkOrderConfig.Task
  alias Inconn2Service.Workorder.WorkorderTask
  alias Inconn2Service.Measurements.MeterReading

  def list_meter_readings(prefix) do
    Repo.all(MeterReading, prefix: prefix)
  end

  def get_meter_reading!(id, prefix), do: Repo.get!(MeterReading, id, prefix: prefix)

  def create_meter_reading(attrs \\ %{}, prefix) do
    %MeterReading{}
    |> MeterReading.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def get_last_cumulative_value(asset_id, asset_type, unit_of_measurement, prefix) do
    query =
      from(mr in MeterReading,
          where: mr.asset_id == ^asset_id and
                 mr.asset_type == ^asset_type and
                 mr.unit_of_measurement == ^unit_of_measurement,
          order_by: [desc: mr.recorded_date_time],
          select: mr.cumulative_value,
          limit: 1)

    Repo.one(query, prefix: prefix)
  end

  def update_meter_reading(%MeterReading{} = meter_reading, attrs, prefix) do
    meter_reading
    |> MeterReading.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_meter_reading(%MeterReading{} = meter_reading, prefix) do
    Repo.delete(meter_reading, prefix: prefix)
  end

  def change_meter_reading(%MeterReading{} = meter_reading, attrs \\ %{}) do
    MeterReading.changeset(meter_reading, attrs)
  end

  def record_meter_readings_from_work_order(work_order, prefix) do
    scheduled_date_time = NaiveDateTime.new!(work_order.scheduled_date, work_order.scheduled_time)
    query = from wot in WorkorderTask,
              join: t in Task, on: t.id == wot.task_id,
              where: wot.work_order_id == ^work_order.id and t.task_type == "MT",
              select: %{
                        recorded_value: wot.response["answers"],
                        recorded_type: t.config["type"],
                        # recorded_date_time: wot.actual_end_time,
                        unit_of_measurement: t.config["UOM"],
                        meter_type: t.config["category"]
                        }

     workorder_tasks = Repo.all(query, prefix: prefix)
                       |> Enum.map(fn x -> Map.put(x, :recorded_date_time, scheduled_date_time) end)

     Enum.map(workorder_tasks, fn workorder_task -> insert_metering_values(work_order, workorder_task, prefix) end)

  end

  def insert_metering_values(work_order, workorder_task, prefix) do
    query = from mr in MeterReading,
              where: [asset_id: ^work_order.asset_id,
                      asset_type: ^work_order.asset_type,
                      unit_of_measurement: ^workorder_task.unit_of_measurement,
                      meter_type: ^workorder_task.meter_type],
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
      "unit_of_measurement" => workorder_task.unit_of_measurement,
      "meter_type" => workorder_task.meter_type,
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
      "unit_of_measurement" => workorder_task.unit_of_measurement,
      "meter_type" => workorder_task.meter_type,
      "work_order_id" => work_order.id
    }
    |> create_meter_reading(prefix)
  end

end
