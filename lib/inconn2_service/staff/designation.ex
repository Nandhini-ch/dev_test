defmodule Inconn2Service.Staff.Designation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "designations" do
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(designation, attrs) do
    designation
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
