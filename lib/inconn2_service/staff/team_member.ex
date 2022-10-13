defmodule Inconn2Service.Staff.TeamMember do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Staff.Team

  schema "team_members" do
    field :employee_id, :integer
    belongs_to :team, Team
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(team_member, attrs) do
    team_member
    |> cast(attrs, [:employee_id, :team_id, :active])
    |> validate_required([:employee_id, :team_id])
  end
end
