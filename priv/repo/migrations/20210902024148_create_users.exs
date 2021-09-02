defmodule Inconn2Service.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :password, :string
      add :role_id, {:array, :integer}

      timestamps()
    end

  end
end
