defmodule Inconn2Service.WorkOrderConfig.TaskList do
  use Ecto.Schema

  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.AssetCategory
  alias Inconn2Service.WorkOrderConfig.Task

  schema "task_lists" do
    field :name, :string
    field :active, :boolean, default: true
    belongs_to :asset_category, AssetCategory
    many_to_many(:tasks, Task, join_through: "task_tasklists", on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(task_list, attrs) do
    task_list
    |> cast(attrs, [:name, :asset_category_id])
    |> validate_required([:name, :asset_category_id])

  end
end
