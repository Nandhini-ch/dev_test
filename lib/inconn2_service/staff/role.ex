defmodule Inconn2Service.Staff.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :name, :string
    field :description, :string
    field :features, {:array, :string}, default: []
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :description, :features, :active])
    |> validate_required([:name, :description, :features])
    |> unique_constraint(:name)
  end
end
