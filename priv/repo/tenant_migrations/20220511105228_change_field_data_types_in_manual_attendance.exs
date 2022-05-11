defmodule Inconn2Service.Repo.Migrations.ChangeFieldDataTypesInManualAttendance do
  use Ecto.Migration

  def change do
    alter table("manual_attendances") do
      remove :worked_hours_in_minutes
      remove :overtime_hours_in_minutes

      add :worked_hours_in_minutes, :float
      add :overtime_hours_in_minutes, :float
    end
  end
end
