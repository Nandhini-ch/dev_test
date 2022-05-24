defmodule Inconn2Service.Repo.Migrations.ChangeFieldsInAttendance do
  use Ecto.Migration

  def change do
    alter table("attendances") do
      remove :latitude
      remove :longitude

      add :latitude, :float
      add :longitude, :float
    end
  end
end
