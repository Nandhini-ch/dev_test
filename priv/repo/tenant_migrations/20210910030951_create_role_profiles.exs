defmodule Inconn2Service.Repo.Migrations.CreateRoleProfiles do
  use Ecto.Migration

  def change do
    create table(:role_profiles) do
      add :label, :string
      add :description, :string
      add :feature_ids, {:array, :integer}
      add :code, :string

      timestamps()
    end
    create unique_index(:role_profiles, [:label])
    create unique_index(:role_profiles, [:code])
  end
end
