defmodule Inconn2Service.Ticket.Approval do
  use Ecto.Schema
  import Ecto.Changeset

  schema "approvals" do
    field :approved, :boolean, default: false
    field :remarks, :string
    # field :user_id, :integer
    belongs_to :user, Inconn2Service.Staff.User
    # field :work_request_id, :integer
    belongs_to :work_request, Inconn2Service.Ticket.WorkRequest
    field :action_at, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(approval, attrs) do
    approval
    |> cast(attrs, [:user_id, :approved, :remarks, :work_request_id, :action_at])
    |> validate_required([:user_id, :approved, :work_request_id, :action_at])
    |> validate_remarks()
    |> assoc_constraint(:user)
    |> assoc_constraint(:work_request)
  end

  def validate_remarks(cs) do
    approved = get_field(cs, :approved, nil)
    if approved != nil do
      case approved do
        false -> validate_required(cs, [:remarks])
        _ -> cs
      end
    else
      cs
    end
  end
end
