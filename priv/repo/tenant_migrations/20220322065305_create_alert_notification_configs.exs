defmodule Inconn2Service.Repo.Migrations.CreateAlertNotificationConfigs do
  use Ecto.Migration

  def change do
    create table(:alert_notification_configs) do
      add :alert_notification_reserve_id, :integer
      add :addressed_to_user_ids, {:array, :integer}
      add :site_id, references(:sites, on_delete: :nothing)

      timestamps()
    end

    create index(:alert_notification_configs, [:site_id])
  end
end
