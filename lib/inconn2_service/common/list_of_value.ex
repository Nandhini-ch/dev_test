defmodule Inconn2Service.Common.ListOfValue do
  use Ecto.Schema
  import Ecto.Changeset

  schema "list_of_values" do
    field :name, :string
    field :values, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(list_of_value, attrs) do
    list_of_value
    |> cast(attrs, [:name, :values])
    |> validate_required([:name, :values])
  end
end
