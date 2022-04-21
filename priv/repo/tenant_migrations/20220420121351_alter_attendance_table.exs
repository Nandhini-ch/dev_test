defmodule Inconn2Service.Repo.Migrations.AlterAttendanceTable do
  use Ecto.Migration

  def change do
    alter table("attendances") do
      remove :shift_id
      remove :date
      remove :attendance_record
      add :date_time, :naive_datetime
      add :latitude, :string
      add :longitude, :string
      add :site_id, :integer
      add :employee_id, :integer
    end
  end
end
