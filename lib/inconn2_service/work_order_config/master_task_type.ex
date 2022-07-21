defmodule Inconn2Service.WorkOrderConfig.MasterTaskType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_task_types" do
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(master_task_type, attrs) do
    master_task_type
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
