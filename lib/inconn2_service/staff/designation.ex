defmodule Inconn2Service.Staff.Designation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "designations" do
    field :description, :string
    field :name, :string
    field :active, :boolean, default: true
    timestamps()
  end

  @doc false
  def changeset(designation, attrs) do
    designation
    |> cast(attrs, [:name, :description, :active])
    |> validate_required([:name])
  end
end
