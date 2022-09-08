defmodule Inconn2Service.Repo.Migrations.CreateRosters do
  use Ecto.Migration

  def change do
    create table(:rosters) do
      add :shift_id, :integer
      add :employee_id, :integer
      add :date, :date
      add :active, :boolean, default: true, null: false
      add :master_roster_id, references(:master_rosters, on_delete: :nothing)

      timestamps()
    end

    create index(:rosters, [:master_roster_id])
  end
end
