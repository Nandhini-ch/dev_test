defmodule Inconn2Service.Ticket.WorkRequest do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Site
  alias Inconn2Service.Ticket.WorkrequestCategory

  schema "work_requests" do
    belongs_to :site, Site
    belongs_to :workrequest_category, WorkrequestCategory
    field :asset_ids, {:array, :integer}
    field :description, :string
    field :priority, :string
    field :request_type, :string
    field :date_of_requirement, :date
    field :time_of_requirement, :time
    field :requested_user_id, :integer
    field :assigned_user_id, :integer
    field :attachment, :string
    field :attachment_type, :string

    timestamps()
  end

  @doc false
  def changeset(work_request, attrs) do
    work_request
    |> cast(attrs, [:site_id, :workrequest_category_id, :asset_ids, :description, :priority, :request_type,
                    :date_of_requirement, :time_of_requirement, :requested_user_id, :assigned_user_id,
                    :attachment, :attachment_type])
    |> validate_required([:site_id, :workrequest_category_id, :description, :priority, :request_type])
    |> validate_inclusion(:priority, ["LW", "MD", "HI", "CR"])
    |> validate_inclusion(:request_type, ["CO", "RE"])
    |> validate_asset_id_mandatory()
    |> assoc_constraint(:site)
    |> assoc_constraint(:workrequest_category)
  end

  defp validate_asset_id_mandatory(cs) do
    req_type = get_field(cs, :request_type, nil)
    if req_type != nil do
      validate_required(cs, :validate_required)
    else
      cs
    end
  end
end
