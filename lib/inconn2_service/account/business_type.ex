defmodule Inconn2Service.Account.BusinessType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "business_types" do
    field :description, :string
    field :name, :string
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(business_type, attrs) do
    business_type
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
