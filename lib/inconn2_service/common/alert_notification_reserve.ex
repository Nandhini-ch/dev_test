defmodule Inconn2Service.Common.AlertNotificationReserve do
  use Ecto.Schema
  import Ecto.Changeset

  schema "alert_notification_reserves" do
    field :code, :string
    field :description, :string
    field :module, :string
    field :type, :string
    field :sms_code, :string
    field :text_template, :string
    field :is_sms_required, :boolean, default: false
    field :is_email_required, :boolean, default: false
    field :is_escalation_required, :boolean, default: false
    field :escalation_time_in_minutes, :integer

    timestamps()
  end

  @doc false
  def changeset(alert_notification_reserve, attrs) do
    alert_notification_reserve
    |> cast(attrs, [:module, :description, :type, :code, :sms_code, :text_template, :is_sms_required, :is_email_required, :is_escalation_required, :escalation_time_in_minutes])
    |> validate_required([:module, :description, :type, :code])
    |> validate_inclusion(:type, ["al", "nt"])
  end
end
