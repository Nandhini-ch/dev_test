defmodule Inconn2Service.Workorder.WorkorderTask do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Workorder.WorkOrder

  schema "workorder_tasks" do
    belongs_to :work_order, WorkOrder
    field :task_id, :integer
    field :sequence, :integer
    field :response, :string

    timestamps()
  end

  @doc false
  def changeset(workorder_task, attrs) do
    workorder_task
    |> cast(attrs, [:task_id, :sequence, :work_order_id, :response])
    |> validate_required([:task_id, :sequence, :work_order_id, :response])
    |> assoc_constraint(:work_order)
  end
end
