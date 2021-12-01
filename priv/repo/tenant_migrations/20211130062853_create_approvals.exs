defmodule Inconn2Service.Repo.Migrations.CreateApprovals do
  use Ecto.Migration

  def change do
    create table(:approvals) do
      add :user_id, :integer
      add :approved, :boolean, default: false, null: false
      add :remarks, :text
      add :work_request_id, :integer
      add :action_at, :naive_datetime

      timestamps()
    end

  end
end
