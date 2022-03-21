defmodule Inconn2Service.Repo.Migrations.CreateAlertNotificationReserves do
  use Ecto.Migration

  def change do
    create table(:alert_notification_reserves) do
      add :module, :string
      add :description, :text
      add :type, :string
      add :code, :string

      timestamps()
    end

  end
end
