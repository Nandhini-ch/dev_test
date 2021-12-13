defmodule Inconn2Service.Ticket.CategoryHelpdesk do
  use Ecto.Schema
  import Ecto.Changeset

  schema "category_helpdesks" do
    belongs_to :user, Inconn2Service.Staff.User
    belongs_to :site, Inconn2Service.AssetConfig.Site
    belongs_to :workrequest_category, Inconn2Service.Ticket.WorkrequestCategory

    timestamps()
  end

  @doc false
  def changeset(category_helpdesk, attrs) do
    category_helpdesk
    |> cast(attrs, [:user_id, :site_id, :workrequest_category_id])
    |> validate_required([:user_id, :site_id, :workrequest_category_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:site)
    |> assoc_constraint(:workrequest_category)
  end
end
