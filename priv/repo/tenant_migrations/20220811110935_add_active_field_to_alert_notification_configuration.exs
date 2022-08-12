defmodule Inconn2Service.Repo.Migrations.AddActiveFieldToAlertNotificationConfiguration do
  use Ecto.Migration

  def change do
    alter table("alert_notification_configs")  do
      add :active, :boolean, default: true
    end
  end
end
