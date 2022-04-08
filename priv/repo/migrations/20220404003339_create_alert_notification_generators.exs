defmodule Inconn2Service.Repo.Migrations.CreateAlertNotificationGenerators do
  use Ecto.Migration

  def change do
    create table(:alert_notification_generators) do
      add :prefix, :string
      add :utc_date_time, :utc_datetime
      add :zone, :string
      add :reference_id, :integer
      add :code, :string

      timestamps()
    end

  end
end
