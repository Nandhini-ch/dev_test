defmodule Inconn2Service.Workorder.WorkorderTask do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Workorder.WorkOrder

  schema "workorder_tasks" do
    belongs_to :work_order, WorkOrder
    field :task_id, :integer
    field :sequence, :integer
    field :response, :map, default: %{"answers" => nil}
    field :remarks, :string
    field :date_time, :naive_datetime
    field :expected_start_time, :naive_datetime
    field :expected_end_time, :naive_datetime
    field :actual_start_time, :naive_datetime
    field :actual_end_time, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(workorder_task, attrs) do
    workorder_task
    |> cast(attrs, [:task_id, :sequence, :work_order_id, :response, :remarks, :expected_start_time, :expected_end_time, :actual_start_time, :actual_end_time, :date_time])
    |> validate_required([:task_id, :sequence, :work_order_id])
    |> assoc_constraint(:work_order)
  end
end
