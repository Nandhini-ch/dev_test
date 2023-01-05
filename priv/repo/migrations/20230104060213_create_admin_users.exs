defmodule Inconn2Service.Repo.Migrations.CreateAdminUser do
  use Ecto.Migration

  def change do
    create table(:admin_user) do
      add :full_name, :string
      add :username, :string
      add :password_hash, :string
      add :phone_no, :string
      add :active, :boolean

      timestamps()
    end

  end
end
