defmodule Inconn2Service.Prompt.AlertNotificationConfig do
  use Ecto.Schema
  import Ecto.Changeset

  schema "alert_notification_configs" do
    field :addressed_to_user_ids, {:array, :integer}
    field :escalated_to_user_ids, {:array, :integer}
    field :alert_notification_reserve_id, :integer
    field :is_escalation_required, :boolean, default: false
    field :escalation_time_in_minutes, :integer
    belongs_to :site, Inconn2Service.AssetConfig.Site

    timestamps()
  end

  @doc false
  def changeset(alert_notification_config, attrs) do
    alert_notification_config
    |> cast(attrs, [:alert_notification_reserve_id, :addressed_to_user_ids, :site_id, :is_escalation_required, :escalation_time_in_minutes, :escalated_to_user_ids])
    |> validate_required([:alert_notification_reserve_id, :addressed_to_user_ids, :is_escalation_required, :site_id])
    |> validate_escalation_time_and_user_ids()
  end

  def validate_escalation_time_and_user_ids(cs) do
    case get_field(cs, :is_escalation_required, nil) do
      true -> validate_required(cs, [:escalation_time_in_minutes, :escalated_to_user_ids])
      _ -> cs
    end
  end
end
