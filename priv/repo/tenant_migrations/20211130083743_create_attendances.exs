defmodule Inconn2Service.Repo.Migrations.CreateAttendances do
  use Ecto.Migration

  def change do
    create table(:attendances) do
      add :shift_id, :integer
      add :date, :date
      add :attendance_record, {:array, :map}

      timestamps()
    end

  end
end
