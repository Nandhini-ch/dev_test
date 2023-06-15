defmodule Inconn2Service.Repo.Migrations.CreateSla do
  use Ecto.Migration

  def change do
    create table(:sla) do
      add :category, :string
      add :criteria, :string
      add :calculation, :string
      add :kpi, :text
      add :type, :string
      add :weightage, :integer
      add :max_score, :integer
      add :approver, :integer
      add :range_list, {:array, :map}
      add :boolean_list, {:array, :map}
      add :count_list, {:array, :map}
      add :contract_id, references(:contracts, on_delete: :nothing)
      add :active, :boolean
      add :cycle, :string
      add :exception, :boolean
      add :exception_value, :integer
      add :justification, :text
      add :status, :string
      add :rejection_reason, :string
      add :config_status, :string

      timestamps()
    end
    create index(:sla, [:contract_id])
  end
end
