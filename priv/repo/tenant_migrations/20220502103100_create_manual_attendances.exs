defmodule Inconn2Service.Repo.Migrations.CreateManualAttendances do
  use Ecto.Migration

  def change do
    create table(:manual_attendances) do
      add :employee_id, :integer
      add :shift_id, :integer
      add :in_time, :naive_datetime
      add :out_time, :naive_datetime
      add :worked_hours_in_minutes, :integer
      add :is_overtime, :boolean, default: false, null: false
      add :overtime_hours_in_minutes, :integer
      add :in_time_marked_by, :integer
      add :out_time_marked_by, :integer
      add :status, :string

      timestamps()
    end

  end
end
