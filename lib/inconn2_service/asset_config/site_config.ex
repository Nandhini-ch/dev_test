defmodule Inconn2Service.AssetConfig.SiteConfig do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Site

  schema "site_config" do
    field :config, :map
    belongs_to :site, Site

    timestamps()
  end

  @doc false
  def changeset(site_config, attrs) do
    site_config
    |> cast(attrs, [:site_id, :config])
    |> validate_required([:site_id])
    |> assoc_constraint(:site)
  end
end
