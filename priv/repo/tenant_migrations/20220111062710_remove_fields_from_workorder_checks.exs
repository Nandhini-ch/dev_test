defmodule Inconn2Service.Repo.Migrations.RemoveFieldsFromWorkorderChecks do
  use Ecto.Migration

  def change do
    alter table("workorder_checks") do
      remove :approved_by_user_id
      remove :remarks
    end
  end
end
