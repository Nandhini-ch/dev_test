defmodule Inconn2Service.Repo.Migrations.AddFieldToTeamAndTeamMember do
  use Ecto.Migration


  def change do
    alter table("teams") do
      add :active, :boolean, default: true, null: false
    end

    alter table("team_members") do
      add :active, :boolean, default: true, null: false
    end

  end
end
