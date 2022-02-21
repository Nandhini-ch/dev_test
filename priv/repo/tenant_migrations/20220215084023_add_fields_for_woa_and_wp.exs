defmodule Inconn2Service.Repo.Migrations.AddFieldsForWoaAndWp do
  use Ecto.Migration

  def change do
    alter table("workorder_templates") do
      remove :workpermit_required
      remove :workpermit_required_from
      add :is_workorder_approval_required, :boolean, null: false, default: false
      add :is_workpermit_required, :boolean, null: false, default: false
      add :is_workorder_acknowledgement_required, :boolean, null: false, default: true
    end

    alter table("work_orders") do
      remove :workpermit_required
      remove :workpermit_required_from
      remove :workpermit_obtained
      add :is_workorder_approval_required, :boolean
      add :is_workpermit_required, :boolean
      add :workorder_approval_user_id, :integer
      add :workpermit_approval_user_ids, {:array, :integer}
      add :workpermit_obtained_from_user_ids, {:array, :integer}
      add :is_workorder_acknowledgement_required, :boolean
      add :workorder_acknowledgement_required_from_user_id, :integer
    end

    alter table("workorder_schedules") do
      add :workorder_approval_user_id, :integer
      add :workpermit_approval_user_ids, {:array, :integer}
      add :workorder_acknowledgement_required_from_user_id, :integer
    end
  end
end
