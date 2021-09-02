defmodule Inconn2Service.Common.WorkScheduler do
  use Ecto.Schema

  import Ecto.Changeset

  schema "work_schedulers" do
    field :prefix, :string
    field :workorder_schedule_id, :integer
    field :zone, :string
    field :utc_date_time, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(asset_category, attrs) do
    asset_category
    |> cast(attrs, [:prefix, :workorder_schedule_id, :zone, :utc_date_time])
    |> validate_required([:prefix, :workorder_schedule_id, :zone])
  end

end
