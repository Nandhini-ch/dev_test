defmodule Inconn2Service.Staff.RoleProfile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "role_profiles" do
    field :name, :string
    field :code, :string
    field :permissions, {:array, :map}, default: []

    timestamps()
  end

  @doc false
  def changeset(role_profile, attrs) do
    role_profile
    |> cast(attrs, [:name, :code, :permissions])
    |> validate_required([:name, :code, :permissions])
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
