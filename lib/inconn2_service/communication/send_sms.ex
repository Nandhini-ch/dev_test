defmodule Inconn2Service.Communication.SendSms do
  use Ecto.Schema
  import Ecto.Changeset

  schema "send_sms" do
    field :delivery_status, :string
    field :error_code, :string
    field :error_message, :string
    field :job_id, :string
    field :message, :string
    field :message_id, :string
    field :mobile_no, :string
    field :template_id, :string
    field :user_id, :integer
    field :date_time, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(send_sms, attrs) do
    send_sms
    |> cast(attrs, [:user_id, :mobile_no, :template_id, :message, :job_id, :message_id, :error_code, :error_message, :delivery_status, :date_time])
    |> validate_required([:mobile_no, :template_id, :message, :job_id, :message_id, :error_code, :error_message])
  end
end
