defmodule Inconn2Service.Workorder.WorkorderStatusTrack do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workorder_status_tracks" do
    field :work_order_id, :integer
    field :status, :string
    field :user_id, :integer
    field :date, :date
    field :time, :time

    timestamps()
  end

  @doc false
  def changeset(workorder_status_track, attrs) do
    workorder_status_track
    |> cast(attrs, [:work_order_id, :status, :user_id, :date, :time])
    |> validate_required([:work_order_id, :status])
  end
end
