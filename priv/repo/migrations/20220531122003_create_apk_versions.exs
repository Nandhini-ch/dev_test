defmodule Inconn2Service.Repo.Migrations.CreateApkVersions do
  use Ecto.Migration

  def change do
    create table(:apk_versions) do
      add :version_no, :string
      add :description, :text

      timestamps()
    end

  end
end
