defmodule Inconn2Service.Repo.Migrations.AddEscaltionFieldToUserAlerts do
  use Ecto.Migration

  def change do
    alter table("alert_notification_schedulers") do
      add :escalated_to_user_ids, {:array, :integer}
    end
  end
end
