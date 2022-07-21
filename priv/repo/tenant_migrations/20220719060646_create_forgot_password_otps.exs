defmodule Inconn2Service.Repo.Migrations.CreateForgotPasswordOtps do
  use Ecto.Migration

  def change do
    create table(:forgot_password_otps) do
      add :user_id, :integer
      add :otp, :integer
      add :created_date_time, :naive_datetime
      add :username, :string
      add :validated, :boolean, default: false

      timestamps()
    end

  end
end
