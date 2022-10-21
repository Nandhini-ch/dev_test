defmodule Inconn2Service.Repo.Migrations.AddEscalationParamsToConfig do
  use Ecto.Migration

  def change do
    alter table("alert_notification_configs") do
      add :is_escalation_required, :boolean, default: false
      add :escalation_time_in_minutes, :integer
      add :escalated_to_user_ids, {:array, :integer}
    end

    alter table("user_alert_notifications") do
      add :alert_identifier_date_time, :naive_datetime
      add :site_id, :integer
    end
  end
end
