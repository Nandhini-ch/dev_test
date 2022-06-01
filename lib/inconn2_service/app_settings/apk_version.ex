defmodule Inconn2Service.AppSettings.Apk_version do
  use Ecto.Schema
  import Ecto.Changeset

  schema "apk_versions" do
    field :version_no, :string
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(apk_version, attrs) do
    apk_version
    |> cast(attrs, [:version_no, :description])
    |> validate_required([:version_no])
  end
end
