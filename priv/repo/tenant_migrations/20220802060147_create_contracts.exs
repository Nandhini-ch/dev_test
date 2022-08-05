defmodule Inconn2Service.Repo.Migrations.CreateContracts do
  use Ecto.Migration

  def change do
    create table(:contracts) do
      add :name, :string
      add :description, :text
      add :start_date, :date
      add :end_date, :date
      add :is_effective_status, :boolean
      add :active, :boolean, default: true
      add :party_id, references(:parties, on_delete: :nothing)
      timestamps()
    end

    create index(:contracts, [:party_id])
  end
end
