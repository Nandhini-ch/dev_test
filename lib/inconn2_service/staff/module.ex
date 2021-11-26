defmodule Inconn2Service.Staff.Module do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Staff.Feature

  schema "modules" do
    field :name, :string
    field :code, :string
    has_many :features, Feature

    timestamps()
  end

  @doc false
  def changeset(module, attrs) do
    module
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
