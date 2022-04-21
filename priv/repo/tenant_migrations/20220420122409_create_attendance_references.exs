defmodule Inconn2Service.Repo.Migrations.CreateAttendanceReferences do
  use Ecto.Migration

  def change do
    create table(:attendance_references) do
      add :employee_id, :integer
      add :reference_image, :binary
      add :status, :string

      timestamps()
    end

  end
end
