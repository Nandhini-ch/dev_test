defmodule Inconn2Service.Repo.Migrations.CreateWorkorderChecks do
  use Ecto.Migration

  def change do
    create table(:workorder_checks) do
      add :check_id, :integer
      add :type, :string
      add :approved_by_user_id, :integer
      add :approved, :boolean, default: false, null: false
      add :remarks, :text
      add :work_order_id, references(:work_orders, on_delete: :nothing)

      timestamps()
    end

    create index(:workorder_checks, [:work_order_id])
  end
end
