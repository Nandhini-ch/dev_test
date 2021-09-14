defmodule Inconn2Service.Repo.Migrations.CreateWorkorderStatusTracks do
  use Ecto.Migration

  def change do
    create table(:workorder_status_tracks) do
      add :work_order_id, :integer
      add :status, :string
      add :user_id, :integer

      timestamps()
    end

  end
end
