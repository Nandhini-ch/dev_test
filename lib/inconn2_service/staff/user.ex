defmodule Inconn2Service.Staff.User do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoCommons.EmailValidator
  import Comeonin

  schema "users" do
    field :password, :string, virtual: true
    field :role_id, {:array, :integer}
    field :username, :string
    field(:password_hash, :string)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :role_id])
    |> validate_required([:username, :password, :role_id])
    |> validate_email(:username, checks: [:html_input, :pow])
    # |> validate_length(:password, min: 6, max: 12)
    #  |> validate_confirmation(:password,
    #   message: "does not match password" )
    |> unique_constraint(:username)
    |> hash_password()
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      pass_hash_map = Argon2.add_hash(password)
      pass_hash = Map.get(pass_hash_map, :password_hash)
      put_change(changeset, :password_hash, pass_hash)
    else
      changeset
    end
  end
end

"""

If you want to verify the hashed password use the following piece of code when necessary

def verify_user(%{"password" => password} = params) do
  params
  |> Accounts.get_by()
  |> Argon2.check_pass(password)
end

"""

# in mix.exs add {:ecto_commons, "~> 0.3.3"}
# EctoCommons.EmailValidator
# There are various :checks depending on the strictness of the validation you require. Indeed, perfect email validation does not exist (see StackOverflow questions about it):

# :html_input: Checks if the email follows the regular expression used by browsers
# for their type="email" input fields. This is the default as it corresponds to most use-cases.
# It is quite strict without being too narrow. It does not support unicode emails though.
# If you need better internationalization, please use the :pow check as it is more
# flexible with international emails. Defaults to enabled.
