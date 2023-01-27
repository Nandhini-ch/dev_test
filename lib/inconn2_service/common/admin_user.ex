defmodule Inconn2Service.Common.AdminUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "admin_user" do
    field :username, :string
    field :full_name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :phone_no, :string
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(admin_user, attrs) do
    admin_user
    |> cast(attrs, [:full_name, :username, :password, :password_hash, :phone_no, :active])
    |> validate_required([:full_name, :username, :password])
    |> hash_password()
  end

  def hash_password(changeset) do
    if password = get_change(changeset, :password) do
      pass_hash_map = Argon2.add_hash(password)
      pass_hash = Map.get(pass_hash_map, :password_hash)
      put_change(changeset, :password_hash, pass_hash)
    else
      changeset
    end
  end

end
