defmodule Inconn2Service.Repo.Migrations.CreateSavedDashboardFilters do
  use Ecto.Migration

  def change do
    create table(:saved_dashboard_filters) do
      add :widget_code, :string
      add :site_id, :integer
      add :user_id, :integer
      add :config, :map
      add :active, :boolean, default: true

      timestamps()
    end

  end
end
