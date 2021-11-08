defmodule Inconn2Service.Repo.Migrations.CreateWorkrequestStatusTrack do
  use Ecto.Migration

  def change do
    create table(:workrequest_status_track) do
      add :status, :string
      add :user_id, :integer
      add :status_update_date, :date
      add :status_update_time, :time
      add :work_request_id, references(:work_requests, on_delete: :nothing)

      timestamps()
    end

    create index(:workrequest_status_track, [:work_request_id])
  end
end
