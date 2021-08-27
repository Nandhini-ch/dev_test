defmodule Inconn2Service.Workorder.WorkorderSchedule do
  use Ecto.Schema
  import Ecto.Changeset

  alias Inconn2Service.Workorder.WorkorderTemplate

  schema "workorder_schedules" do
    belongs_to :workorder_template, WorkorderTemplate
    field :asset_id, :integer
    field :config, :map
    field :next_occurance, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(workorder_schedule, attrs) do
    workorder_schedule
    |> cast(attrs, [:workorder_template_id, :asset_id, :config])
    |> validate_required([:workorder_template_id, :asset_id, :config])
  end
end
