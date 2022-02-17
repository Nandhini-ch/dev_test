defmodule Inconn2Service.Repo.Migrations.CreateWorkorderApprovalTracks do
  use Ecto.Migration

  def change do
    create table(:workorder_approval_tracks) do
      add :type, :string
      add :approved, :boolean, default: false, null: false
      add :remarks, :text
      add :discrepancy_workorder_check_ids, {:array, :integer}
      add :work_order_id, references(:work_orders, on_delete: :nothing)
      add :approval_user_id, :integer

      timestamps()
    end

    create index(:workorder_approval_tracks, [:work_order_id])
  end
end
