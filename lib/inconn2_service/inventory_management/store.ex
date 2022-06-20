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
    field :is_layout_configuration_required, :boolean
    field :store_image, :binary
    field :store_image_type, :string
    field :store_image_name, :string
    field :site_id, :integer
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(store, attrs) do
    store
    |> cast(attrs, [:name, :description, :location_id, :site_id, :person_or_location_based, :user_id, :is_layout_configuration_required, :store_image,
                              :store_image_type, :store_image_name, :aisle_count, :aisle_notation, :row_count, :row_notation, :bin_count, :bin_notation, :site_id, :active])
    |> validate_required([:name, :person_or_location_based])
    |> validate_inclusion(:person_or_location_based, ["P", "L"])
    |> validate_inclusion(:store_image_type, ["image/apng", "image/avif", "image/gif", "image/jpeg", "image/png", "image/webp"])
    |> validate_user_id_if_person_based_store()
    |> validate_location_and_site_if_location_based_store()
    |> validate_bin_details_if_layout_configuration_required()
  end

  def update_changeset(store, attrs) do
    attrs = Map.new(Enum.filter(attrs, fn {_key, value} -> value != "null" end))
    store
    |> cast(attrs, [:name, :description, :store_image, :store_image_type, :store_image_name, :active])
    |> validate_inclusion(:store_image_type, ["image/apng", "image/avif", "image/gif", "image/jpeg", "image/png", "image/webp"])
  end

  defp validate_user_id_if_person_based_store(cs) do
    if get_field(cs, :person_or_location_based, nil) == "P" do
      validate_required(cs, [:user_id])
    else
      cs
    end
  end

  def validate_location_and_site_if_location_based_store(cs) do
    if get_field(cs, :person_or_location_based, nil) == "L" do
      validate_required(cs, [:site_id, :location_id, :is_layout_configuration_required])
    else
      cs
    end
  end

  def validate_bin_details_if_layout_configuration_required(cs) do
    if get_change(cs, :is_layout_configuration_required, nil) do
      cs
       |> validate_required([:aisle_count, :aisle_notation, :row_count, :row_notation, :bin_count, :bin_notation])
       |> validate_inclusion(:aisle_notation, ["U", "L", "N"])
       |> validate_inclusion(:bin_notation, ["U", "L", "N"])
       |> validate_inclusion(:row_notation, ["U", "L", "N"])
    else
      cs
    end
  end

end
