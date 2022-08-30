defmodule Inconn2Service.Repo.Migrations.AddActiveToDesignations do
  use Ecto.Migration

  def change do
    alter table("designations") do
      add :active, :boolean
    end
  end
end
