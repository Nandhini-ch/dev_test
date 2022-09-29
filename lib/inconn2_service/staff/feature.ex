defmodule Inconn2Service.Staff.Feature do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Staff.Module

  schema "features" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(feature, attrs) do
    feature
    |> cast(attrs, [:name, :code])
    |> validate_required([:name, :code])
    |> unique_constraint(:name)
    |> unique_constraint(:code)
    |> validate_code()
  end

  defp validate_code(cs) do
    code = get_field(cs, :code, nil)
    if code != nil do
      length = String.length(code)
      case length == 4 and code =~ ~r(^[^a-z]*$) do
        true -> cs
        false -> add_error(cs, :code, "should be 4 uppercase alphabets")
      end
    else
      cs
    end
  end
end
