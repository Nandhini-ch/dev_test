defmodule Inconn2Service.Repo.Migrations.CreateManpowerConfigurations do
  use Ecto.Migration

  def change do
    create table(:manpower_configurations) do
      add :site_id, :integer
      add :designation_id, :integer
      add :shift_id, :integer
      add :quantity, :integer
      add :active, :boolean
      add :contract_id, references(:contracts, on_delete: :nothing)


      timestamps()
    end

    create index(:manpower_configurations, [:contract_id])
  end
end
