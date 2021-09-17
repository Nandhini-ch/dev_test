defmodule Inconn2Service.Repo.Migrations.CreateEmployeeRosters do
  use Ecto.Migration

  def change do
    create table(:employee_rosters) do
      add :employee_id, :integer
      add :site_id, :integer
      add :shift_id, :integer
      add :start_date, :date
      add :end_date, :date

      timestamps()
    end

  end
end
