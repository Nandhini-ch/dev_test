defmodule Inconn2Service.AssetConfig.SiteConfig do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Site

  @dash_config [
    "energy_asset_category", "water_asset_category", "fuel_asset_category",
    "energy_main_meters", "energy_non_main_meters", "water_main_meters", "fuel_main_meters",
    "energy_cost_per_unit", "water_cost_per_unit", "fuel_cost_per_unit",
    "generators", "area_in_sqft"
]

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
        if Map.keys(config) -- @dash_config == [] do
          changeset
        else
          add_error(changeset, :config, "config is invalid")
        end

      "ATT" ->
        # if Map.keys(config) == ["grace_period_in_minutes", "half_day_work_hours", "preferred_total_work_hours"] do
        if Map.keys(config) == ["grace_period_in_minutes", "half_day_work_hours"] do
          changeset
        else
          add_error(changeset, :config, "config is invalid")
        end

      _ ->
        changeset
    end
  end

end
