defmodule Inconn2Service.Repo.Migrations.AddCreatedFieldsToWorkorder do
  use Ecto.Migration

  def change do
    alter table("work_orders") do
      add :created_user_id, :integer
    end
  end
end
