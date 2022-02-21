defmodule Inconn2Service.Workorder.WorkorderApprovalTrack do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workorder_approval_tracks" do
    field :approved, :boolean, default: false
    field :discrepancy_workorder_check_ids, {:array, :integer}
    field :remarks, :string
    field :type, :string
    field :approval_user_id, :integer
    belongs_to :work_order, Inconn2Service.Workorder.WorkOrder

    timestamps()
  end

  @doc false
  def changeset(workorder_approval_track, attrs) do
    workorder_approval_track
    |> cast(attrs, [:work_order_id, :approval_user_id, :type, :approved, :remarks, :discrepancy_workorder_check_ids])
    |> validate_required([:work_order_id, :type, :approved])
    |> validate_inclusion(:type, ["WP", "LOTO", "WOA", "ACK"])
    |> validate_remarks_required()
    |> assoc_constraint(:work_order)
  end

  defp validate_remarks_required(cs) do
    approved = get_change(cs, :approved, nil)
    type = get_field(cs, :type, nil)
    if approved do
      cs
    else
      if type == "WP" do
        validate_required(cs, [:remarks, :discrepancy_workorder_check_ids])
      else
        validate_required(cs, [:remarks])
      end
    end
  end
end
