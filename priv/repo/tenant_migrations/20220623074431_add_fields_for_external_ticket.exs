defmodule Inconn2Service.Repo.Migrations.AddFieldsForExternalTicket do
  use Ecto.Migration

  def change do
    alter table("work_requests") do
      add :is_external_ticket, :boolean, default: false
      add :external_name, :string
      add :external_email, :string
      add :external_mobile_no, :string
      add :remarks, :string
    end
  end
end
