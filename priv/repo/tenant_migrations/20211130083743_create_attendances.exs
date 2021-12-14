defmodule Inconn2Service.Repo.Migrations.CreateAttendances do
  use Ecto.Migration

  def change do
    create table(:attendances) do
      add :shift_id, references(:shifts, on_delete: :nothing)
      add :date, :date
      add :attendance_record, {:array, :map}

      timestamps()
    end

    create index(:attendances, [:shift_id])
  end
end
