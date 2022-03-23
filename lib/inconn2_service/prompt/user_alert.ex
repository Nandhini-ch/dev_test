defmodule Inconn2Service.Prompt.UserAlert do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_alerts" do
    field :alert_id, :integer
    field :alert_type, :string
    field :asset_id, :integer
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(user_alert, attrs) do
    user_alert
    |> cast(attrs, [:alert_id, :alert_type, :user_id, :asset_id])
    |> validate_required([:alert_id, :alert_type, :user_id, :asset_id])
  end
end
