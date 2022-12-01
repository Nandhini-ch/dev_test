defmodule Inconn2Service.DashboardConfiguration.SavedDashboardFilter do
  use Ecto.Schema
  import Ecto.Changeset

  schema "saved_dashboard_filters" do
    field :name, :string
    field :config, :map
    field :site_id, :integer
    field :user_id, :integer
    field :widget_code, :string
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(saved_dashboard_filter, attrs) do
    saved_dashboard_filter
    |> cast(attrs, [:name, :widget_code, :site_id, :user_id, :config, :active])
    |> validate_required([:name, :widget_code, :site_id, :user_id, :config])
  end
end
