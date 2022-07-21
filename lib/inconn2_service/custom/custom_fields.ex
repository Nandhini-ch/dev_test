defmodule Inconn2Service.Custom.CustomFields do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Common.CustomFieldEmbed

  schema "custom_fields" do
    field :entity, :string
    # field :fields, {:array, :map}
    embeds_many :fields, CustomFieldEmbed, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(custom_fields, attrs) do
    custom_fields
    |> cast(attrs, [:entity])
    |> validate_required([:entity])
    |> unique_constraint(:entity)
    |> cast_embed(:fields)
  end
end
