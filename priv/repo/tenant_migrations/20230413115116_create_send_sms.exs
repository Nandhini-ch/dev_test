defmodule Inconn2Service.Repo.Migrations.CreateSendSms do
  use Ecto.Migration

  def change do
    create table(:send_sms) do
      add :user_id, :integer
      add :mobile_no, :string
      add :template_id, :string
      add :message, :string
      add :job_id, :string
      add :message_id, :string
      add :error_code, :string
      add :error_message, :string
      add :delivery_status, :string
      add :date_time, :naive_datetime

      timestamps()
    end

  end
end
