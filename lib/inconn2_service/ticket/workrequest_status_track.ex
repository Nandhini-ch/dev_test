defmodule Inconn2Service.Ticket.WorkrequestStatusTrack do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workrequest_status_track" do
    field :status, :string
    field :user_id, :integer
    field :status_update_time, :time
    field :status_update_date, :date
    belongs_to :work_request, Inconn2Service.Ticket.WorkRequest
    timestamps()
  end

  @doc false
  def changeset(workrequest_status_track, attrs) do
    workrequest_status_track
    |> cast(attrs, [:status, :user_id, :status_update_time, :status_update_date, :work_request_id])
    |> validate_required([:status, :status_update_time, :status_update_date, :work_request_id])
  end
end
