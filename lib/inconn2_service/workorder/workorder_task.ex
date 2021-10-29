defmodule Inconn2Service.Workorder.WorkorderTask do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Workorder.WorkOrder

  schema "workorder_tasks" do
    belongs_to :work_order, WorkOrder
    field :task_id, :integer
    field :sequence, :integer
    field :response, :string
    field :response_date, :date
    field :response_time, :time

    timestamps()
  end

  @doc false
  def changeset(workorder_task, attrs) do
    workorder_task
    |> cast(attrs, [:task_id, :sequence, :work_order_id, :response, :response_date, :response_time])
    |> validate_required([:task_id, :sequence, :work_order_id, :response, :response_date, :response_time])
    |> assoc_constraint(:work_order)
  end
end
