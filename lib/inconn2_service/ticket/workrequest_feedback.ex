defmodule Inconn2Service.Ticket.WorkrequestFeedback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workrequest_feedbacks" do
    field :email, :string
    field :rating, :integer
    field :site_id, :integer
    field :user_id, :integer
    field :work_request_id, :integer

    timestamps()
  end

  @doc false
  def changeset(workrequest_feedback, attrs) do
    workrequest_feedback
    |> cast(attrs, [:work_request_id, :user_id, :email, :site_id, :rating])
    |> validate_required([:work_request_id, :site_id, :rating])
  end
end
