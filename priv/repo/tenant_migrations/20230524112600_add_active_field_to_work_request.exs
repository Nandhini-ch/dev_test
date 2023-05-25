defmodule Inconn2Service.Repo.Migrations.AddActiveFieldToWorkRequest do
  use Ecto.Migration

  def change do
    alter table("work_requests") do
      add :active, :boolean
    end

  end
end
