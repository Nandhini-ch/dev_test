defmodule Inconn2Service.Repo.Migrations.CreateAttendanceFailureLogs do
  use Ecto.Migration

  def change do
    create table(:attendance_failure_logs) do
      add :employee_id, :integer
      add :failure_image, :binary
      add :date_time, :naive_datetime

      timestamps()
    end

  end
end
