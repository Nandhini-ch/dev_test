defmodule Inconn2Service.Repo.Migrations.AddPauseResumeTimesToWorkOrder do
  use Ecto.Migration

  def change do
    alter table("work_orders") do
      add :pause_resume_times, {:array, :map}, default: []
    end
  end
end
