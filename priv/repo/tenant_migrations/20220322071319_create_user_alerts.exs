defmodule Inconn2Service.Repo.Migrations.CreateUserAlerts do
  use Ecto.Migration

  def change do
    create table(:user_alert_notifications) do
      add :alert_notification_id, :integer
      add :type, :string
      add :user_id, :integer
      add :asset_id, :integer
      add :description, :text
      add :remarks, :text

      timestamps()
    end

  end
end
