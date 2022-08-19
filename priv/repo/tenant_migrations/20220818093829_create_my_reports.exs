defmodule Inconn2Service.Repo.Migrations.CreateMyReports do
  use Ecto.Migration

  def change do
    create table(:my_reports) do
      add :name, :string
      add :description, :string
      add :code, :string
      add :report_params, :map
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:my_reports, [:user_id])
  end
end
