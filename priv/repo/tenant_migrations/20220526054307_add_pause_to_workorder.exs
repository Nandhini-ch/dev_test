defmodule Inconn2Service.Repo.Migrations.AddPauseToWorkorder do
  use Ecto.Migration

  def change do
    alter table("work_orders") do
      add :is_paused, :boolean, default: false
    end
  end
end
