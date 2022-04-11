defmodule Inconn2Service.Common.AlertNotificationReserve do
  use Ecto.Schema
  import Ecto.Changeset

  schema "alert_notification_reserves" do
    field :code, :string
    field :description, :string
    field :module, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(alert_notification_reserve, attrs) do
    alert_notification_reserve
    |> cast(attrs, [:module, :description, :type, :code])
    |> validate_required([:module, :description, :type, :code])
    |> validate_inclusion(:type, ["al", "nt"])
  end
end
