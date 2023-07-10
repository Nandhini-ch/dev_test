defmodule Inconn2Service.Staff.Role do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Staff.RoleProfile

  schema "roles" do
    belongs_to :role_profile, RoleProfile
    field :name, :string
    field :description, :string
    field :permissions, {:array, :map}, default: []
    field :hierarchy_id, :integer
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :description, :role_profile_id, :permissions, :hierarchy_id, :active])
    |> validate_required([:name, :role_profile_id, :permissions])
    |> unique_constraint(:name)
    |> unique_constraint(:unique_roles, [name: :unique_roles, message: "Role name already exists"])
    |> assoc_constraint(:role_profile)
  end
end
