defmodule Inconn2Service.Staff.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :description, :string
    field :name, :string
    field :active, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :description, :active])
    |> validate_required([:name])
  end
end
