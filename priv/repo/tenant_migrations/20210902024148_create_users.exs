defmodule Inconn2Service.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :mobile_no, :string
      add :password_hash, :string
      add :role_id, :integer
      add :party_id, references(:parties, on_delete: :nothing)
      add :employee_id, references(:employees, on_delete: :delete_all)
      add :active, :boolean

      timestamps()
    end
    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
    create index(:users, [:party_id])
    create index(:users, [:employee_id])
  end
end
