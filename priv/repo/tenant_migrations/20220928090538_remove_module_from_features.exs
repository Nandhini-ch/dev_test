defmodule Inconn2Service.Repo.Migrations.RemoveModuleFromFeatures do
  use Ecto.Migration

  def change do
    alter table("features") do
      remove :module_id
    end
  end
end
