defmodule Inconn2Service.AssetConfig.SiteConfig do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Site

  schema "site_config" do
    field :config, :map
    field :type, :string
    belongs_to :site, Site

    timestamps()
  end

  @doc false
  def changeset(site_config, attrs) do
    site_config
    |> cast(attrs, [:site_id, :config, :type])
    |> validate_required([:site_id, :config, :type])
    |> validate_inclusion(:type, ["DASH", "ATT"])
    |> validate_config()
    |> assoc_constraint(:site)
  end

  def validate_config(changeset) do
    config = get_field(changeset, :config)
    type = get_field(changeset, :type)
    case type do
      "DASH" ->
        if Map.keys(config) == ["area", "energy_cost_per_unit", "main_meters", "standard_value_for_deviation"] do
          changeset
        else
          add_error(changeset, :config, "config is invalid")
        end

      "ATT" ->
        if Map.keys(config) == ["grace_period_for_in_time", "half_day_work_hours", "preferred_total_work_hours"] do
          changeset
        else
          add_error(changeset, :config, "config is invalid")
        end

      _ ->
        changeset
    end
  end

end
