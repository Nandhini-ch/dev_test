defmodule Inconn2Service.InventoryManagement do

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.InventoryManagement.{UomCategory, UnitOfMeasurement}


  def list_uom_categories(prefix) do
    Repo.all(UomCategory, prefix: prefix)
  end

  def get_uom_category!(id, prefix), do: Repo.get!(UomCategory, id, prefix: prefix)

  def create_uom_category(attrs \\ %{}, prefix) do
    %UomCategory{}
    |> UomCategory.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_uom_category(%UomCategory{} = uom_category, attrs, prefix) do
    uom_category
    |> UomCategory.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_uom_category(%UomCategory{} = uom_category, prefix) do
    Repo.delete(uom_category, prefix: prefix)
  end

  def change_uom_category(%UomCategory{} = uom_category, attrs \\ %{}) do
    UomCategory.changeset(uom_category, attrs)
  end

  #Unit of measurement context functions
  def list_unit_of_measurements(prefix) do
    Repo.all(UnitOfMeasurement, prefix: prefix)
  end

  def list_unit_of_measurements_by_uom_category(uom_category_id, prefix) do
    from(uom in UnitOfMeasurement, where: uom.uom_category_id == ^uom_category_id)
    |> Repo.all(prefis: prefix)
  end

  def get_unit_of_measurement!(id, prefix), do: Repo.get!(UnitOfMeasurement, id, prefix: prefix)

  def create_unit_of_measurement(attrs \\ %{}, prefix) do
    %UnitOfMeasurement{}
    |> UnitOfMeasurement.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_unit_of_measurement(%UnitOfMeasurement{} = unit_of_measurement, attrs, prefix) do
    unit_of_measurement
    |> UnitOfMeasurement.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_unit_of_measurement(%UnitOfMeasurement{} = unit_of_measurement, prefix) do
    Repo.delete(unit_of_measurement, prefix: prefix)
  end

  def change_unit_of_measurement(%UnitOfMeasurement{} = unit_of_measurement, attrs \\ %{}) do
    UnitOfMeasurement.changeset(unit_of_measurement, attrs)
  end
end
