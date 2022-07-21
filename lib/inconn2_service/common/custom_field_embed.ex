defmodule Inconn2Service.Common.CustomFieldEmbed do
  import Ecto.Changeset
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :field_name, :string
    field :field_label, :string
    field :field_type, :string
    field :field_placeholder, :string
  end

  def changeset(address_embed, attrs) do
    address_embed
    |> cast(attrs, [:field_name, :field_label, :field_type, :field_placeholder])
    |> validate_required([:field_label, :field_type])
    |> set_snake_case_name()
    |> validate_required([:field_name])
    |> validate_inclusion(:field_type, ["text", "string", "date", "time", "integer", "float", "list_of_values"])
  end

  defp set_snake_case_name(cs) do
    label = get_field(cs, :field_label, nil)
    cond do
      !is_nil(label) -> change(cs, %{field_name: String.downcase(label) |> String.replace(" ", "_")})
      true -> cs
    end
  end
end
