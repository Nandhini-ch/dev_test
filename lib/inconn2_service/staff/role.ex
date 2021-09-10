defmodule Inconn2Service.Staff.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
  end
end
