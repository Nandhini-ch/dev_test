defmodule Inconn2Service.Repo.Migrations.AddFieldsToPrompt do
  use Ecto.Migration

  def change do
    alter table("user_alert_notifications") do
      add :priority, :string
    end

    alter table("alert_notification_configs") do
      add :priority, :string
    end

  end
end
