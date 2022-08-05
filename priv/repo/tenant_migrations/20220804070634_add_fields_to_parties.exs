defmodule Inconn2Service.Repo.Migrations.AddFieldsToParty do
  use Ecto.Migration

  def change do
    alter table("parties")  do
      add :pan_number, :string
    end
  end
end
