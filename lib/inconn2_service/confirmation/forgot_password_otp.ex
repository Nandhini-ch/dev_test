defmodule Inconn2Service.Confirmation.ForgotPasswordOtp do
  use Ecto.Schema
  import Ecto.Changeset

  schema "forgot_password_otps" do
    field :created_date_time, :naive_datetime
    field :otp, :integer
    field :user_id, :integer
    field :username, :string
    field :validated, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(forgot_password_otp, attrs) do
    forgot_password_otp
    |> cast(attrs, [:user_id, :otp, :created_date_time, :username, :validated])
    |> validate_required([:user_id, :otp, :created_date_time, :username])
  end
end
