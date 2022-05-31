defmodule Inconn2Service.InventoryManagement.Store do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stores" do
    field :aisle_count, :integer
    field :aisle_notation, :string
    field :bin_count, :integer
    field :bin_notation, :string
    field :description, :string
    field :location_id, :integer
    field :name, :string
    field :row_count, :integer
    field :row_notation, :string
    field :person_or_location_based, :string
    field :user_id, :integer
    field :is_layout_configuration_required, :boolean, default: false
    belongs_to :site, Inconn2Service.AssetConfig.Site

    timestamps()
  end

  @doc false
  def changeset(store, attrs) do
    store
    |> cast(attrs, [:name, :description, :location_id, :aisle_count, :aisle_notation, :row_count, :row_notation, :bin_count, :bin_notation, :site_id])
    |> validate_required([:name, :location_id, :aisle_count, :aisle_notation, :row_count, :row_notation, :bin_count, :bin_notation])
    |> validate_inclusion(:aisle_notation, ["U", "L", "N"])
    |> validate_inclusion(:bin_notation, ["U", "L", "N"])
    |> validate_inclusion(:row_notation, ["U", "L", "N"])
    |> validate_inclusion(:person_or_location_based, ["P", "L"])
    |> validate_user_id_if_person_based()
    |> validate_location_and_site_if_location_based()
  end

  defp validate_user_id_if_person_based(cs) do
    person_or_location_based = get_field(cs, :person_or_location_based)
    user_id = get_field(cs, :user_id)
    cond do
      person_or_location_based == "P" && is_nil(user_id) ->
        add_error(cs, :user_id, "User Id needs to be provided for Person based store")

      true ->
        cs
    end
  end

  def validate_location_and_site_if_location_based(cs) do
    person_or_location_based = get_field(cs, :person_or_location_based)
    site_id = get_field(cs, :site_id)
    location_id = get_field(cs, :location_id)
    cond do
      person_or_location_based == "L" && is_nil(site_id) && is_nil(location_id) ->
        add_error(cs, :site_id, "Site is required for Location based store")
        |> add_error(:location_id, "Location is required for location based store")

      person_or_location_based == "L" && is_nil(site_id) ->
        add_error(cs, :site_id, "Site is required for Location based store")

      person_or_location_based == "L" && is_nil(location_id) ->
        add_error(cs, :location_id, "Location is required for Location based store")

      true ->
        cs
    end
  end
end
