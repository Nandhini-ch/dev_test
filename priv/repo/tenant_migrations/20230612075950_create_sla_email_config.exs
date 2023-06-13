defmodule Inconn2Service.Repo.Migrations.CreateSlaEmailConfig do
  use Ecto.Migration

  def change do
    create table(:sla_email_config) do
      add :category, :string
      add :email_list, :jsonb

      timestamps()
    end
  end
end
