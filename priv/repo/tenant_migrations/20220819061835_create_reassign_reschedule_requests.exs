defmodule Inconn2Service.Repo.Migrations.CreateReassignRescheduleRequests do
  use Ecto.Migration

  def change do
    create table(:reassign_reschedule_requests) do
      add :requester_user_id, :integer
      add :reassign_to_user_id, :integer
      add :reports_to_user_id, :integer
      add :reschedule_date, :date
      add :reschedule_time, :time
      add :request_for, :string
      add :status, :string
      add :work_order_id, references(:work_orders, on_delete: :nothing)

      timestamps()
    end

    create index(:reassign_reschedule_requests, [:work_order_id])
  end
end
