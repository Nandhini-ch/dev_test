defmodule Inconn2Service.Repo.Migrations.AddFieldToAttendances do
  use Ecto.Migration

  def change do
    alter table("attendances") do
      add :status, :string
    end
  end
end
