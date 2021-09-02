defmodule Inconn2Service.Staff.User do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoCommons.EmailValidator

  schema "users" do
    field :password, :string
    field :role_id, {:array, :integer}
    field :username, :string
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :role_id])
    |> validate_required([:username, :password, :role_id])
    |> validate_email(:username, checks: [:html_input, :pow])
  end
end

# in mix.exs add {:ecto_commons, "~> 0.3.3"}
# EctoCommons.EmailValidator
# There are various :checks depending on the strictness of the validation you require. Indeed, perfect email validation does not exist (see StackOverflow questions about it):

# :html_input: Checks if the email follows the regular expression used by browsers
# for their type="email" input fields. This is the default as it corresponds to most use-cases.
# It is quite strict without being too narrow. It does not support unicode emails though.
# If you need better internationalization, please use the :pow check as it is more
# flexible with international emails. Defaults to enabled.
