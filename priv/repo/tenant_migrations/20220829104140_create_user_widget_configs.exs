defmodule Inconn2Service.Repo.Migrations.CreateUserWidgetConfigs do
  use Ecto.Migration

  def change do
    create table(:user_widget_configs) do
      add :widget_code, :string
      add :position, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

  end
end
