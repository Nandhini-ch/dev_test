defmodule Inconn2Service.Repo.Migrations.CreateChecks do
  use Ecto.Migration

  def change do
    create table(:checks) do
      add :label, :string
      add :type, :string

      timestamps()
    end

  end
end
