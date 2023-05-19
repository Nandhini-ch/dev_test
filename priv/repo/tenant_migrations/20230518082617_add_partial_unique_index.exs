defmodule Inconn2Service.Repo.Migrations.AddPartialUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:alert_notification_configs, [:site_id, :alert_notification_reserve_id], where: "active = 'true'", name: :unique_alert_config)
  end
end
