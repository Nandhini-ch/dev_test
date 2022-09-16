defmodule Inconn2Service.Repo.Migrations.CreateTeamMembers do
  use Ecto.Migration

  def change do
    create table(:team_members) do
      add :employee_id, :integer
      add :team_id, references(:teams, on_delete: :nothing)

      timestamps()
    end

    create index(:team_members, [:team_id])
  end
end
