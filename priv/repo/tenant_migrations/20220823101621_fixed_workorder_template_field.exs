defmodule Inconn2Service.Repo.Migrations.FixedWorkorderTemplateFields do
  use Ecto.Migration

  def change do
    alter table("workorder_templates") do
      remove :ahdoc
      add :adhoc, :boolean, default: false
    end
  end
end
