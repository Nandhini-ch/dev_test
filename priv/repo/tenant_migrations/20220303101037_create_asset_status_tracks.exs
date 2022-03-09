defmodule Inconn2Service.Repo.Migrations.CreateAssetStatusTracks do
  use Ecto.Migration

  def change do
    create table(:asset_status_tracks) do
      add :asset_id, :integer
      add :asset_type, :string
      add :status_changed, :string
      add :user_id, :integer
      add :changed_date_time, :naive_datetime
      add :hours, :float

      timestamps()
    end

  end
end
