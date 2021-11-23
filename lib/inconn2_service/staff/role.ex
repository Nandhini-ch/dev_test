defmodule Inconn2Service.Staff.Role do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Staff.RoleProfile

  schema "roles" do
    belongs_to :role_profile, RoleProfile
    field :name, :string
    field :description, :string
    field :feature_ids, {:array, :integer}, default: []
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :description, :role_profile_id, :feature_ids, :active])
    |> validate_required([:name, :feature_ids, :role_profile_id])
    |> unique_constraint(:name)
    |> assoc_constraint(:role_profile)
  end
end
