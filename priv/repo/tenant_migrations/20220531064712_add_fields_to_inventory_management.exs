defmodule Inconn2Service.Repo.Migrations.AddFieldsToInventoryManagement do
  use Ecto.Migration

  def change do
    alter table("stores") do
      add :person_or_user_based, :string
      add :user_id, :integer
      add :is_layout_configuration_required, :boolean, default: false
    end
  end
end
