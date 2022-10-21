defmodule Inconn2Service.Repo.Migrations.AddFieldsForFacialAttendance do
  use Ecto.Migration

  def change do
    alter table("attendances") do
      remove :date_time
      add :in_time, :naive_datetime
      add :out_time, :naive_datetime
      add :shift_id, :integer
    end
  end
end
