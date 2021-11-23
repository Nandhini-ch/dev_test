defmodule Inconn2Service.Staff.RoleProfile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "role_profiles" do
    field :label, :string
    field :code, :string
    field :description, :string
    field :feature_ids, {:array, :integer}, default: []

    timestamps()
  end

  @doc false
  def changeset(role_profile, attrs) do
    role_profile
    |> cast(attrs, [:label, :feature_ids, :code, :description])
    |> validate_required([:label, :feature_ids, :code])
    |> unique_constraint(:label)
    |> unique_constraint(:code)
    |> validate_code()
  end

  defp validate_code(cs) do
    code = get_field(cs, :code, nil)
    if code != nil do
      length = String.length(code)
      case length == 3 and code =~ ~r(^[^a-z]*$) do
        true -> cs
        false -> add_error(cs, :code, "should be 3 uppercase alphabets")
      end
    else
      cs
    end
  end
end
