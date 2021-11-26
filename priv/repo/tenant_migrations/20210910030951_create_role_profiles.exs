defmodule Inconn2Service.Repo.Migrations.CreateRoleProfiles do
  use Ecto.Migration

  def change do
    create table(:role_profiles) do
      add :name, :string
      add :code, :string
      add :permissions, {:array, :map}

      timestamps()
    end
    create unique_index(:role_profiles, [:name])
    create unique_index(:role_profiles, [:code])
  end
end
