defmodule Inconn2Service.Repo.Migrations.AddFieldsToUsersAndSites do
  use Ecto.Migration

  def change do
    alter table("users")  do
      add :first_name, :string
      add :last_name, :string
    end

    alter table("sites")  do
      add :zone_id, references(:zones, on_delete: :nothing)
    end

    create index(:sites, [:zone_id])
  end
end
