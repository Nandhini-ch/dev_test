defmodule Inconn2Service.Common.Widget do
  use Ecto.Schema
  import Ecto.Changeset

  schema "widgets" do
    field :code, :string
    field :description, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(widget, attrs) do
    widget
    |> cast(attrs, [:code, :description, :title])
    |> validate_required([:code, :title])
    |> unique_constraint(:code)
  end
end
