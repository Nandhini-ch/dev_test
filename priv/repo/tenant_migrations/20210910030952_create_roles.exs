defmodule Inconn2Service.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string
      add :description, :string
      add :feature_ids, {:array, :integer}
      add :role_profile_id, references(:role_profiles, on_delete: :nothing)
      add :active, :boolean

      timestamps()
    end
    create index(:roles, [:role_profile_id])
    create unique_index(:roles, [:name])

  end
end
