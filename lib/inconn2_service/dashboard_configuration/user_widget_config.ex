defmodule Inconn2Service.DashboardConfiguration.UserWidgetConfig do
  alias Inconn2Service.Staff.User
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_widget_configs" do
    field :position, :integer
    field :widget_code, :string
    field :device, :string
    field :size, :integer, default: 1
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(user_widget_config, attrs) do
    user_widget_config
    |> cast(attrs, [:widget_code, :position, :user_id, :device, :size])
    |> validate_required([:widget_code, :position, :user_id, :device, :size])
    |> validate_inclusion(:device, ["web", "mob"])
  end
end
