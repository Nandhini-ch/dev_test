defmodule Inconn2Service.Repo.Migrations.CreateSiteConfig do
  use Ecto.Migration

  def change do
    create table(:site_config) do
      add :config, :map
      add :site_id, references(:sites, on_delete: :delete_all)

      timestamps()
    end

    create index(:site_config, [:site_id])
  end
end
