defmodule Inconn2Service.Prompt.UserAlertNotification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_alert_notifications" do
    field :alert_notification_id, :integer
    field :alert_identifier_date_time, :naive_datetime
    field :type, :string
    field :asset_id, :integer
    field :asset_type, :string
    field :site_id, :integer
    field :user_id, :integer
    field :description, :string
    field :remarks, :string
    field :acknowledged_date_time, :naive_datetime
    field :action_taken, :boolean, default: false
    field :escalation, :boolean, default: false
    field :priority, :string, default: "medium"

    timestamps()
  end

  @doc false
  def changeset(user_alert, attrs) do
    user_alert
    |> cast(attrs, [:alert_notification_id, :type, :user_id, :asset_id, :description, :remarks, :asset_type,
                    :action_taken, :acknowledged_date_time, :alert_identifier_date_time, :site_id, :escalation])
    |> validate_required([:alert_notification_id, :type, :user_id, :description])
    |> validate_inclusion(:type, ["al", "nt"])
    |> validate_inclusion(:priority, ["medium", "high"])
  end
end
