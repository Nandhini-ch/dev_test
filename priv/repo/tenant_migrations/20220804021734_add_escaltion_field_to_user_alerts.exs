defmodule Inconn2Service.Repo.Migrations.AddEscaltionFieldToUserAlerts do
  use Ecto.Migration

  def change do
    alter table("user_alert_notifications") do
      add :escalation, :boolean, default: false
    end
  end
end
