defmodule Inconn2Service.Repo.Migrations.AddFieldsToReassignReschedule do
  use Ecto.Migration

  def change do
    alter table("reassign_reschedule_requests") do
      add :requested_datetime, :naive_datetime
    end
  end
end
