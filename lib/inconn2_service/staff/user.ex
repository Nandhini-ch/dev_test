defmodule Inconn2Service.Staff.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Comeonin
  alias Inconn2Service.AssetConfig.Party
  alias Inconn2Service.Staff.Employee

  schema "users" do
    field :username, :string
    field :first_name, :string
    field :last_name, :string
    field :password, :string, virtual: true
    field :first_login, :boolean, default: true
    field :role_id, :integer
    field :email, :string
    field :mobile_no, :string
    field :password_hash, :string
    belongs_to :employee, Employee
    belongs_to :party, Party
    field :active, :boolean, default: true
    timestamps()
  end

  # belongs_to :role, Role
  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :first_name, :last_name, :password, :email, :first_login, :mobile_no, :role_id, :party_id, :employee_id, :active])
    |> validate_required([:username, :password, :email, :mobile_no, :role_id, :party_id])
    |> validate_format(:email, ~r/@/)
    |> validate_confirmation(:password, message: "does not match password")
    # |> validate_length(:password, min: 6, max: 12)
    #  |> validate_confirmation(:password,
    #   message: "does not match password" )
    |> unique_constraint(:username)
    # |> unique_constraint(:email)
    |> hash_password()
    |> assoc_constraint(:party)
    |> assoc_constraint(:employee)
  end

  def changeset_update(user, attrs) do
    user
    |> cast(attrs, [:username, :first_name, :last_name, :email, :mobile_no, :role_id, :party_id, :employee_id, :active])
    |> validate_required([:username, :role_id, :party_id])
    |> validate_format(:username, ~r/@/)
    |> unique_constraint(:username)
    |> assoc_constraint(:party)
  end

  def change_password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password, :first_login])
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
