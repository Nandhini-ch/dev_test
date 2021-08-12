defmodule Inconn2Service.Common.ContactEmbed do
  import Ecto.Changeset
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :first_name, :string
    field :last_name, :string
    field :designation, :string
    field :land_line, :string
    field :mobile, :string
    field :email, :string
  end

  def changeset(contact_embed, attrs) do
    contact_embed
    |> cast(attrs, [:first_name, :last_name, :designation, :land_line, :mobile, :email])
    |> validate_required([:first_name, :last_name, :designation, :land_line, :mobile, :email])
  end
end
