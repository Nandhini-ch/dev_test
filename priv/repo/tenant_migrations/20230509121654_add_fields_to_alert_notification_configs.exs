defmodule Inconn2Service.Repo.Migrations.AddFieldsToAlertNotificationConfigs do
  use Ecto.Migration

  def change do
    alter table("alert_notification_configs") do
      add :addressed_to_users, {:array, :map}
      add :escalated_to_users, {:array, :map}
      add :is_sms_required, :boolean
      add :is_email_required, :boolean
    end
  end
end
