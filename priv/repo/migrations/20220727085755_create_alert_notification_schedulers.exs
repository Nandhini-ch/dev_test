defmodule Inconn2Service.Repo.Migrations.CreateAlertNotificationSchedulers do
  use Ecto.Migration

  def change do
    create table(:alert_notification_schedulers) do
      add :alert_identifier_date_time, :naive_datetime
      add :alert_code, :string
      add :site_id, :integer
      add :escalation_at_date_time, :naive_datetime
      add :prefix, :string

      timestamps()
    end

  end
end
