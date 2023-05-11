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
  end
end
