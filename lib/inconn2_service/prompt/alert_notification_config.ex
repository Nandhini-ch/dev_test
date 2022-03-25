defmodule Inconn2Service.Prompt.AlertNotificationConfig do
  use Ecto.Schema
  import Ecto.Changeset

  schema "alert_notification_configs" do
    field :addressed_to_user_ids, {:array, :integer}
    field :alert_notification_reserve_id, :integer
    belongs_to :site, Inconn2Service.AssetConfig.Site

    timestamps()
  end

  @doc false
  def changeset(alert_notification_config, attrs) do
    alert_notification_config
    |> cast(attrs, [:alert_notification_reserve_id, :addressed_to_user_ids,:site_id])
    |> validate_required([:alert_notification_reserve_id, :addressed_to_user_ids])
  end
end
