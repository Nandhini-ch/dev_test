defmodule Inconn2Service.WorkOrderConfig.TaskList do
  use Ecto.Schema

  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.AssetCategory

  schema "task_lists" do
    field :name, :string
    field :task_ids, {:array, :integer}
    field :active, :boolean, default: true
    belongs_to :asset_category, AssetCategory

    timestamps()
  end

  @doc false
  def changeset(task_list, attrs) do
    task_list
    |> cast(attrs, [:name, :task_ids, :asset_category_id, :active])
    |> validate_required([:name, :task_ids, :asset_category_id])
  end
end
