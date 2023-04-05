defmodule Inconn2Service.Repo.Migrations.AddFieldToUserWidgetConfigs do
  use Ecto.Migration

  def change do
    alter table("user_widget_configs") do
      add :size, :integer
    end

    alter table("locations") do
      add :iot_details, :map
      add :is_iot_enabled, :boolean
    end

    alter table("equipments") do
      add :iot_details, :map
      add :is_iot_enabled, :boolean
    end
  end
end
