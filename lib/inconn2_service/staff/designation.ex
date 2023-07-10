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
    |> unique_constraint([:name])
    |> unique_constraint(:unique_designations, [name: :unique_designations, message: "Designation name already exists"])
  end
end
