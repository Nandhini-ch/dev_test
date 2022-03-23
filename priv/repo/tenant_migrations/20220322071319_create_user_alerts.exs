defmodule Inconn2Service.Repo.Migrations.CreateUserAlerts do
  use Ecto.Migration

  def change do
    create table(:user_alerts) do
      add :alert_id, :integer
      add :alert_type, :string
      add :user_id, :integer
      add :asset_id, :integer

      timestamps()
    end

  end
end
