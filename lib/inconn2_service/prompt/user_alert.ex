defmodule Inconn2Service.Prompt.UserAlert do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_alert_notifications" do
    field :alert_notification_id, :integer
    field :type, :string
    field :asset_id, :integer
    field :user_id, :integer
    field :description, :string
    field :remarks, :string

    timestamps()
  end

  @doc false
  def changeset(user_alert, attrs) do
    user_alert
    |> cast(attrs, [:alert_notification_id, :type, :user_id, :asset_id, :description, :remarks])
    |> validate_required([:alert_notification_id, :type, :user_id, :asset_id])
  end
end
