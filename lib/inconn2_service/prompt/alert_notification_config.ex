defmodule Inconn2Service.Prompt.AlertNotificationConfig do
  use Ecto.Schema
  import Ecto.Changeset

  schema "alert_notification_configs" do
    field :alert_notification_reserve_id, :integer
    field :is_escalation_required, :boolean, default: false
    field :escalation_time_in_minutes, :integer
    field :active, :boolean, default: true
    field :addressed_to_users, {:array, :map}, default: []
    field :escalated_to_users, {:array, :map}, default: []
    field :is_sms_required, :boolean, default: false
    field :is_email_required, :boolean, default: false
    field :priority, :string, default: "normal"
    belongs_to :site, Inconn2Service.AssetConfig.Site

    timestamps()
  end

  @doc false
  def changeset(alert_notification_config, attrs) do
    alert_notification_config
    |> cast(attrs, [:alert_notification_reserve_id, :site_id, :is_escalation_required, :escalation_time_in_minutes, :addressed_to_users, :escalated_to_users, :is_sms_required, :is_email_required, :active, :priority])
    |> validate_required([:alert_notification_reserve_id, :is_escalation_required, :site_id])
    |> validate_escalation_time_and_user_ids()
    |> unique_constraint([:site_id, :alert_notification_reserve_id])
    |> unique_constraint(:unique_alert_config, [name: :unique_alert_config, message: "Already configured for this site"])
    |> validate_inclusion(:priority, ["normal", "high"])
  end

  def validate_escalation_time_and_user_ids(cs) do
    case get_field(cs, :is_escalation_required, nil) do
      true -> validate_required(cs, [:escalation_time_in_minutes, :escalated_to_users])
      _ -> cs
    end
  end
end
