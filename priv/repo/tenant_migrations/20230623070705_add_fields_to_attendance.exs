defmodule Inconn2Service.Repo.Migrations.AddFieldsToAttendance do
  use Ecto.Migration

  def change do
    alter table("attendances") do
      add :roster_id, :integer
    end

  end
end
