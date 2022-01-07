defmodule Inconn2Service.Repo.Migrations.AddFieldsToWorkOrder do
  use Ecto.Migration

  def change do
    alter table("work_orders") do
      add :workpermit_required, :boolean
      add :workpermit_required_from, {:array, :integer}
      add :workpermit_obtained, {:array, :integer}
      add :loto_required, :boolean
      add :loto_approval_from_user_id, :integer
      add :is_loto_obtained, :boolean
      add :pre_check_required, :boolean
      add :precheck_completed, :boolean
    end
  end
end
