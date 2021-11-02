defmodule Inconn2Service.Inventory.Supplier do
  use Ecto.Schema
  import Ecto.Changeset

  alias Inconn2Service.Common.{ContactEmbed}

  schema "suppliers" do
    field :name, :string
    field :description, :string
    embeds_one :contact, ContactEmbed, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(supplier, attrs) do
    supplier
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> cast_embed(:contact)
  end
end
