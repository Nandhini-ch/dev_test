defmodule Inconn2Service.Common.Timezone do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timezones" do
    field :city, :string
    field :continent, :string
    field :label, :string
    field :state, :string
    field :utc_offset_seconds, :integer
    field :utc_offset_text, :string

    timestamps()
  end

  @doc false
  def changeset(timezone, attrs) do
    timezone
    |> cast(attrs, [
      :label,
      :continent,
      :state,
      :city,
      :utc_offset_text,
      :utc_offset_seconds
    ])
    |> validate_required([
      :label,
      :continent,
      :city,
      :utc_offset_text,
      :utc_offset_seconds
    ])
  end
end
