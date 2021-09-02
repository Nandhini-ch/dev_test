defmodule Inconn2Service.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :password_hash, :string
      add :role_id, {:array, :integer}

      timestamps()
    end
    create unique_index(:users, [:username])
  end
end
