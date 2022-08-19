defmodule Inconn2Service.Reapportion.ReassignRescheduleRequest do
  use Ecto.Schema
  import Ecto.Changeset

  alias Inconn2Service.Workorder.WorkOrder

  schema "reassign_reschedule_requests" do
    field :reassign_to_user_id, :integer
    field :reports_to_user_id, :integer
    field :requester_user_id, :integer
    field :reschedule_date, :date
    field :reschedule_time, :time
    field :request_for, :string
    field :status, :string
    # field :work_order_id, :id
    belongs_to :work_order, WorkOrder

    timestamps()
  end

  @doc false
  def changeset(reassign_reschedule_request, attrs) do
    reassign_reschedule_request
    |> cast(attrs, [:requester_user_id, :reassign_to_user_id, :reports_to_user_id, :reschedule_date, :reschedule_time, :request_for, :work_order_id, :status])
    |> validate_required([:requester_user_id, :work_order_id, :request_for])
    |> validate_inclusion(:request_for, ["REAS", "RESC"])
    |> validate_inclusion(:status, ["PD", "AP", "RJ"])
  end

  def update_for_reassign_changeset(reassign_reschedule_request, attrs) do
    reassign_reschedule_request
    |> cast(attrs, [:reassign_to_user_id, :status])
    |> validate_required([:status])
    |> validate_inclusion(:status, ["AP", "RJ"])
    |> validate_user_if_approved()
  end

  defp validate_user_if_approved(cs) do
    case get_field(cs, :status, nil) do
      "AP" -> validate_required(cs, [:reassign_to_user_id])
      _ -> cs
    end
  end
end
