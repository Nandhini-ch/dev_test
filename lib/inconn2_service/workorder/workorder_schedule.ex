defmodule Inconn2Service.Workorder.WorkorderSchedule do
  use Ecto.Schema
  import Ecto.Changeset

  alias Inconn2Service.Workorder.WorkorderTemplate

  schema "workorder_schedules" do
    belongs_to :workorder_template, WorkorderTemplate
    field :asset_id, :integer
    field :asset_type, :string
    field :holidays, {:array, :integer}, default: []
    field :first_occurrence_date, :date
    field :first_occurrence_time, :time
    field :next_occurrence_date, :date
    field :next_occurrence_time, :time
    field :workorder_approval_user_id, :integer
    field :workorder_acknowledgement_from_user_id, :integer
    field :workpermit_approval_user_ids, {:array, :integer}
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(workorder_schedule, attrs) do
    workorder_schedule
    |> cast(attrs, [:workorder_template_id, :asset_id, :holidays, :first_occurrence_date, :first_occurrence_time, :active, :workorder_approval_user_id, :workpermit_approval_user_ids, :workorder_acknowledgement_from_user_id])
    |> validate_required([:workorder_template_id, :asset_id, :first_occurrence_date, :first_occurrence_time])
    |> assoc_constraint(:workorder_template)
  end
end
