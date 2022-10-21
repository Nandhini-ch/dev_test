defmodule Inconn2Service.Assignments.Roster do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Assignments.MasterRoster

  schema "rosters" do
    field :active, :boolean, default: true
    field :date, :date
    field :employee_id, :integer
    field :shift_id, :integer
    belongs_to :master_roster, MasterRoster

    timestamps()
  end

  @doc false
  def changeset(roster, attrs) do
    roster
    |> cast(attrs, [:master_roster_id, :shift_id, :employee_id, :date, :active])
    |> validate_required([:master_roster_id, :shift_id, :employee_id, :date, :active])
    |> assoc_constraint(:master_roster)
  end
end
