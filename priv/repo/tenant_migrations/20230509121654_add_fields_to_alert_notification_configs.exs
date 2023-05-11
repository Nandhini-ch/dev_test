defmodule Inconn2Service.Repo.Migrations.AddFieldsToAlertNotificationConfigs do
  use Ecto.Migration

  def change do
    alter table("alert_notification_configs") do
      remove :addressed_to_user_ids, {:array, :integer}
      remove :escalated_to_user_ids, {:array, :integer}
      add :addressed_to_users, {:array, :map}
      add :escalated_to_users, {:array, :map}
      add :is_sms_required, :boolean
      add :is_email_required, :boolean
    end

    alter table("alert_notification_schedulers") do
      remove :escalated_to_user_ids, {:array, :integer}
      add :escalated_to_users, {:array, :map}
    end

    alter table("user_alert_notifications") do
      add :escalated_to_users, {:array, :map}
    end
  end
end
