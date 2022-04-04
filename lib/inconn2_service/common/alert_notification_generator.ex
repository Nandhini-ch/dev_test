defmodule Inconn2Service.Common.AlertNotificationGenerator do
  use Ecto.Schema
  import Ecto.Changeset

  schema "alert_notification_generators" do
    field :code, :string
    field :prefix, :string
    field :reference_id, :integer
    field :utc_date_time, :utc_datetime
    field :zone, :string

    timestamps()
  end

  @doc false
  def changeset(alert_notification_generator, attrs) do
    alert_notification_generator
    |> cast(attrs, [:prefix, :utc_date_time, :zone, :reference_id, :code])
    |> validate_required([:prefix, :utc_date_time, :zone, :reference_id, :code])
  end
end
