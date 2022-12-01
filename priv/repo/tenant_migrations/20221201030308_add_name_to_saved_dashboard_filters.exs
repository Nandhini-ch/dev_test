defmodule Inconn2Service.Repo.Migrations.AddNameToSavedDashboardFilters do
  use Ecto.Migration

  def change do
    alter table("saved_dashboard_filters") do
      add :name, :string
    end
  end
end
