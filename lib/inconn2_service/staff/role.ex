defmodule Inconn2Service.Staff.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :name, :string
    field :description, :string
    field :feature_ids, {:array, :integer}, default: []
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :description, :feature_ids, :active])
    |> validate_required([:name, :feature_ids])
    |> unique_constraint(:name)
  end
end
