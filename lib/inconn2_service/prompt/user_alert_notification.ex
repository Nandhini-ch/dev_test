
defmodule Inconn2Service.Prompt.UserAlertNotification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_alert_notifications" do
    field :alert_notification_id, :integer
    field :type, :string
    field :asset_id, :integer
    field :asset_type, :string
    field :user_id, :integer
    field :description, :string
    field :remarks, :string
    field :acknowledged_date_time, :naive_datetime
    field :action_taken, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(user_alert, attrs) do
    user_alert
    |> cast(attrs, [:alert_notification_id, :type, :user_id, :asset_id, :description, :remarks, :asset_type, :action_taken, :acknowledged_date_time])
    |> validate_required([:alert_notification_id, :type, :user_id, :description])
    |> validate_inclusion(:type, ["al", "nt"])
  end
end
