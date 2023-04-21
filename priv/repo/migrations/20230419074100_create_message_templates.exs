defmodule Inconn2Service.Repo.Migrations.CreateMessageTemplates do
  use Ecto.Migration

  def change do
    create table(:message_templates) do
      add :message, :string
      add :template_name, :string
      add :dlt_template_id, :string
      add :telemarketer_id, :string
      add :code, :string

      timestamps()
    end

  end
end
