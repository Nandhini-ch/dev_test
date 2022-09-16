defmodule Inconn2Service.Repo.Migrations.AddFieldsToUserWidgetConfigs do
  use Ecto.Migration

  def change do
    alter table("user_widget_configs") do
      add :device, :string
    end
  end
end
