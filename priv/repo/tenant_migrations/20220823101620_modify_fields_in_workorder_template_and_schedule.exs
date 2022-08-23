defmodule Inconn2Service.Repo.Migrations.ModifyFieldsInWorkorderTemplateAndSchedule do
  use Ecto.Migration

  def change do
    alter table("workorder_templates") do
      add :breakdown, :boolean, default: false
      add :audit, :boolean, default: false
      add :adhoc, :boolean, default: false
      add :description, :string
      add :is_precheck_required, :boolean, default: false
      add :precheck_list_id, :integer
      add :is_materials_required, :boolean, default: false
      add :is_manpower_required, :boolean, default: false
      add :materials, {:array, :map}, default: []
      add :manpower, {:array, :map}, default: []
      add :parts, {:array, :map}, default: []
      add :measuring_instruments, {:array, :map}, default: []
      remove :tasks
    end

    alter table("check_lists") do
      remove :site_id
    end
  end
end
