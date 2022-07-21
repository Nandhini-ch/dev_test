defmodule Inconn2Service.WorkOrderConfig.TaskTasklist do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.WorkOrderConfig.{Task, TaskList}

  schema "task_tasklists" do
    belongs_to(:task, Task)
    belongs_to(:task_list, TaskList)
    field :sequence, :integer

    timestamps()
  end

  @doc false
  def changeset(task_tasklist, attrs) do
    task_tasklist
    |> cast(attrs, [:task_id, :task_list_id, :sequence])
    |> validate_required([:task_id, :task_list_id, :sequence])
  end
end
