defmodule Inconn2Service.Ticket.WorkrequestSubcategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workrequest_subcategories" do
    field :description, :string
    field :name, :string
    belongs_to :workrequest_category, Inconn2Service.Ticket.WorkrequestCategory

    timestamps()
  end

  @doc false
  def changeset(workrequest_subcategory, attrs) do
    workrequest_subcategory
    |> cast(attrs, [:name, :description, :workrequest_category_id])
    |> validate_required([:name, :workrequest_category_id])
    |> assoc_constraint(:workrequest_category)
  end
end
