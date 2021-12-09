defmodule Inconn2Service.Repo.Migrations.CreateEmployeeRosters do
  use Ecto.Migration

  def change do
    create table(:employee_rosters) do
      add :employee_id, references(:employees, on_delete: :nothing)
      add :site_id, references(:sites, on_delete: :nothing)
      add :shift_id, references(:shifts, on_delete: :nothing)
      add :start_date, :date
      add :end_date, :date
      add :active, :boolean

      timestamps()
    end

    create index(:employee_rosters, [:employee_id])
    create index(:employee_rosters, [:site_id])
    create index(:employee_rosters, [:shift_id])

  end
end
