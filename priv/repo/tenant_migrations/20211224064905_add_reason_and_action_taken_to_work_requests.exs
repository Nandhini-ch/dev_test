defmodule Inconn2Service.Repo.Migrations.AddReasonAndActionTakenToWorkRequests do
  use Ecto.Migration

  def change do
    alter table("work_requests") do
      add :reason, :text
      add :action_taken, :text
    end
  end
end
