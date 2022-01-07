defmodule Inconn2Service.Repo.Migrations.AddFieldsToWorkorderTemplate do
  use Ecto.Migration

  def change do
    alter table("workorder_templates") do
      add :workpermit_required_from, {:array, :boolean}
      add :loto_approval_from_user_id, :integer
      add :pre_check_required, :boolean
      add :pre_check_list_id, :integer
    end
  end
end
