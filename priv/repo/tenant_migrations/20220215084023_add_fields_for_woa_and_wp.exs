defmodule Inconn2Service.Repo.Migrations.AddFieldsForWoaAndWp do
  use Ecto.Migration

  def change do
    alter table("workorder_templates") do
      remove :workpermit_required
      remove :workpermit_required_from
      remove :loto_required
      remove :loto_approval_from_user_id
      remove :loto_lock_check_list_id
      remove :loto_release_check_list_id
      remove :pre_check_required
      remove :pre_check_list_id
      add :is_workorder_approval_required, :boolean, null: false, default: false
      add :is_workpermit_required, :boolean, null: false, default: false
      add :is_workorder_acknowledgement_required, :boolean, null: false, default: true
      add :is_loto_required, :boolean, null: false, default: false
      add :loto_lock_check_list_id, :integer
      add :loto_release_check_list_id, :integer
    end

    alter table("work_orders") do
      remove :workpermit_required
      remove :workpermit_required_from
      remove :workpermit_obtained
      remove :loto_required
      remove :loto_approval_from_user_id
      remove :is_loto_obtained
      add :is_workorder_approval_required, :boolean
      add :is_workpermit_required, :boolean
      add :workorder_approval_user_id, :integer
      add :workpermit_approval_user_ids, {:array, :integer}
      add :workpermit_obtained_from_user_ids, {:array, :integer}
      add :is_workorder_acknowledgement_required, :boolean
      add :workorder_acknowledgement_user_id, :integer
      add :is_loto_required, :boolean
      add :loto_lock_check_list_id, :integer
      add :loto_release_check_list_id, :integer
      add :loto_checker_user_id, :integer
    end

    alter table("workorder_schedules") do
      add :workorder_approval_user_id, :integer
      add :workpermit_approval_user_ids, {:array, :integer}
      add :workorder_acknowledgement_user_id, :integer
      add :loto_checker_user_id, :integer
    end

    alter table("check_lists") do
      add :site_id, :integer
    end
  end
end
