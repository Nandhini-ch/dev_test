defmodule Inconn2Service.Repo.Migrations.AddIsPausedToWorkorderSchedule do
  use Ecto.Migration

  def change do
    alter table("workorder_schedules") do
      add :is_paused, :boolean, default: :false
    end
  end
end
