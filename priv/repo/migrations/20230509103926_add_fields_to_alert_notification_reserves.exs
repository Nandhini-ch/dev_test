defmodule Inconn2Service.Repo.Migrations.AddFieldsToAlertNotificationReserves do
  use Ecto.Migration

  def change do
    alter table("alert_notification_reserves") do
      add :sms_code, :string
      add :text_template, :string
      add :is_sms_required, :boolean
      add :is_email_required, :boolean
      add :is_escalation_required, :boolean
      add :escalation_time_in_minutes, :integer
    end

    alter table("alert_notification_schedulers") do
      remove :escalated_to_user_ids, {:array, :integer}
      add :escalated_to_users, {:array, :map}
    end
  end
end
