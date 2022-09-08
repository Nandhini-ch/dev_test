defmodule Inconn2Service.Repo.Migrations.CreateMasterRosters do
  use Ecto.Migration

  def change do
    create table(:master_rosters) do
      add :active, :boolean, default: true, null: false
      add :site_id, references(:sites, on_delete: :nothing)
      add :designation_id, references(:designations, on_delete: :nothing)

      timestamps()
    end

    create index(:master_rosters, [:site_id])
    create index(:master_rosters, [:designation_id])
  end
end
