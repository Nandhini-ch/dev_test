defmodule Inconn2Service.Common.WorkRequestCloseScheduler do
  use Ecto.Schema
  import Ecto.Changeset

  schema "work_request_close_schedulers" do
    field :prefix, :string
    field :time_zone, :string
    field :utc_date_time, :utc_datetime
    field :work_request_id, :integer

    timestamps()
  end

  @doc false
  def changeset(work_request_close_scheduler, attrs) do
    work_request_close_scheduler
    |> cast(attrs, [:work_request_id, :prefix, :utc_date_time, :time_zone])
    |> validate_required([:work_request_id, :prefix, :utc_date_time])
  end
end
