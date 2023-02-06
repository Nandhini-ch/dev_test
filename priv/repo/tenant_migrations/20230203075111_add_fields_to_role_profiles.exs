defmodule Inconn2Service.Repo.Migrations.AddFieldsToRoleProfilesAndRoles do
  use Ecto.Migration

  def change do
    alter table("role_profiles") do
      add :hierarchy_id, :integer
    end

    alter table("roles") do
      add :hierarchy_id, :integer
    end

    alter table("users") do
      add :first_login, :boolean,  default: true
    end

  end

end
