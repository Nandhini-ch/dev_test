defmodule Inconn2Service.Repo.Migrations.AddFieldsToTransaction do
  use Ecto.Migration

  def change do
    alter table("transactions") do
      add :requester_name, :string
      add :emp_id, :string
      add :authorized_by, :string
      add :department, :string
    end

    alter table("stores") do
      add :storekeeper_user_id, :integer
    end
  end
end
