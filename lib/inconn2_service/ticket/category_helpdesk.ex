defmodule Inconn2Service.Ticket.CategoryHelpdesk do
  use Ecto.Schema
  import Ecto.Changeset

  schema "category_helpdesks" do
    field :active, :boolean, default: true
    belongs_to :user, Inconn2Service.Staff.User
    belongs_to :site, Inconn2Service.AssetConfig.Site
    belongs_to :workrequest_category, Inconn2Service.Ticket.WorkrequestCategory

    timestamps()
  end

  @doc false
  def changeset(category_helpdesk, attrs) do
    category_helpdesk
    |> cast(attrs, [:user_id, :site_id, :workrequest_category_id, :active])
    |> validate_required([:user_id, :site_id, :workrequest_category_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:site)
    |> assoc_constraint(:workrequest_category)
    # |> unique_constraint(:site_id)
    # |> unique_constraint(:user_id)
    # |> unique_constraint(:workrequest_category_id)
    # |> unique_constraint(:unique_category_helpdesks, [name: :unique_category_helpdesks, message: "Category Helpdesk is already exists"])
  end
end
