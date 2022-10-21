defmodule Inconn2Service.Ticket.WorkRequest do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.{Site, Location}
  alias Inconn2Service.Ticket.{WorkrequestCategory, WorkrequestSubcategory}

  schema "work_requests" do
    belongs_to :site, Site
    belongs_to :workrequest_category, WorkrequestCategory
    belongs_to :workrequest_subcategory, WorkrequestSubcategory
    belongs_to :location, Location
    field :asset_id, :integer
    field :asset_type, :string
    field :description, :string
    field :priority, :string
    field :request_type, :string
    field :time_of_requirement, :naive_datetime
    field :raised_date_time, :naive_datetime
    belongs_to :requested_user, Inconn2Service.Staff.User, foreign_key: :requested_user_id
    belongs_to :assigned_user, Inconn2Service.Staff.User, foreign_key: :assigned_user_id
    field :attachment, :string
    field :attachment_type, :string
    field :status, :string, default: "RS"
    field :is_approvals_required, :boolean
    field :approvals_required, {:array, :integer}
    field :reason, :string
    field :action_taken, :string
    field :response_tat, :integer
    field :resolution_tat, :integer
    field :work_order_id, :integer
    field :is_external_ticket, :boolean, default: false
    field :external_name, :string
    field :external_email, :string
    field :external_mobile_no, :string
    field :remarks, :string
    field :is_workorder_generated, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(work_request, attrs) do
    work_request
    |> cast(attrs, [:site_id, :workrequest_category_id, :workrequest_subcategory_id, :location_id, :asset_id, :asset_type, :description, :priority, :request_type,
                    :time_of_requirement, :requested_user_id, :assigned_user_id, :approvals_required,
                    :attachment, :attachment_type, :is_approvals_required, :status, :work_order_id, :raised_date_time,
                    :response_tat, :resolution_tat, :is_external_ticket, :remarks, :is_workorder_generated])
    |> validate_required([:site_id, :location_id, :workrequest_subcategory_id, :request_type])
    |> validate_inclusion(:asset_type, ["L", "E"])
    |> validate_inclusion(:priority, ["LW", "MD", "HI", "CR"])
    |> validate_inclusion(:request_type, ["CO", "RE"])
    |> validate_inclusion(:status, ["RS", "AP", "AS", "RJ", "CL", "CP", "ROP", "CS"])
    |> assoc_constraint(:site)
    |> assoc_constraint(:workrequest_category)
    |> assoc_constraint(:workrequest_subcategory)
    |> assoc_constraint(:location)
    |> validate_approvals_required()
  end

  def external_ticket_changeset(work_request, attrs) do
    work_request
    |> cast(attrs, [:site_id, :workrequest_category_id, :workrequest_subcategory_id, :location_id, :asset_id, :asset_type, :description, :raised_date_time, :request_type,
                    :is_external_ticket, :external_name, :external_email, :external_mobile_no, :status, :remarks])
    |> validate_required([:site_id, :workrequest_category_id, :workrequest_subcategory_id, :location_id, :asset_id, :asset_type, :description, :raised_date_time, :request_type,
                          :is_external_ticket, :external_name, :external_email, :external_mobile_no])
    |> validate_inclusion(:asset_type, ["L", "E"])
    |> validate_inclusion(:request_type, ["CO", "RE"])
    |> assoc_constraint(:site)
    |> assoc_constraint(:workrequest_category)
    |> assoc_constraint(:workrequest_subcategory)
    |> assoc_constraint(:location)
  end

  def validate_approvals_required(cs) do
    approvals_required = get_field(cs, :is_approvals_required, nil)
    if approvals_required != nil do
      case approvals_required do
        true -> validate_required(cs, [:approvals_required])
           _ -> cs
      end
    else
      cs
    end
  end

end
