defmodule Inconn2Service.Repo.Migrations.AddAndDeleteWoAndWpFieldsToWorkorderTemplate do
  use Ecto.Migration

  def change do
    alter table("workorder_templates") do
      remove :workpermit_required
      remove :workpermit_required_from
      add :is_workorder_approval_required, :boolean, default: false
      add :is_workpermit_required, :boolean, default: false
    end

    alter table("workorder_schedules") do
      add :workorder_approval_user_id, :integer
      add :workpermit_approval_user_ids, {:array, :integer}
    end

    alter table("work_orders") do
      remove :workpermit_required
      remove :workpermit_obtained
      remove :workpermit_required_from
      add :workorder_approval_user_id, :integer
      add :workpermit_approval_user_ids, {:array, :integer}
      add :workpermit_obtained_from_user_ids, {:array, :integer}
    end
  end
end
