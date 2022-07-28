defmodule Inconn2Service.Common.AlertNotificationScheduler do
  use Ecto.Schema
  import Ecto.Changeset

  schema "alert_notification_schedulers" do
    field :alert_code, :string
    field :alert_identifier_date_time, :naive_datetime
    field :escalation_at_date_time, :naive_datetime
    field :site_id, :integer
    field :prefix

    timestamps()
  end

  @doc false
  def changeset(alert_notification_scheduler, attrs) do
    alert_notification_scheduler
    |> cast(attrs, [:alert_identifier_date_time, :alert_code, :site_id, :escalation_at_date_time, :prefix])
    |> validate_required([:alert_identifier_date_time, :alert_code, :site_id, :escalation_at_date_time, :prefix])
  end
end
