defmodule Inconn2Service.Repo.Migrations.AddCheckTypeIdToChecks do
  use Ecto.Migration

  def change do
    alter table("checks") do
      remove :type
      add :check_type_id, :integer
    end
  end
end
