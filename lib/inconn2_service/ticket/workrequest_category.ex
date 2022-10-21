defmodule Inconn2Service.Ticket.WorkrequestCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workrequest_categories" do
    field :description, :string
    field :name, :string
    field :active, :boolean, default: true
    has_many :workrequest_subcategories, Inconn2Service.Ticket.WorkrequestSubcategory

    timestamps()
  end

  @doc false
  def changeset(workrequest_category, attrs) do
    workrequest_category
    |> cast(attrs, [:name, :description, :active])
    |> validate_required([:name])
  end
end
