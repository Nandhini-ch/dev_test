defmodule Inconn2Service.AssetConfig.DuplicateEntry do
  alias Inconn2Service.AssetConfig
  import Ecto.Query, warn: false
  alias Inconn2Service.Staff
  alias Inconn2Service.Settings
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Inventory

  def find_duplicate_entries_in_designations(prefix) do
    designations = Staff.list_designations(prefix)

    duplicates = Enum.filter(designations, fn d ->
      Enum.count(designations, &(&1.name == d.name)) > 1
    end)

    header = [["id", "Name", "active"]]

    body =
      Enum.map(duplicates, fn d ->
        [d.id, d.name, d.active]
      end)

    final_report = header ++ body
    final_report
  end

  def find_duplicate_entry_in_roles(prefix) do
    roles = Staff.list_roles(prefix)

    duplicates = Enum.filter(roles, fn r ->
      Enum.count(roles, &(&1.name == r.name)) > 1
    end)

    header = [["id", "Name", "active"]]

    body =
      Enum.map(duplicates, fn d ->
        [d.id, d.name, d.active]
      end)

    final_report = header ++ body
    final_report
  end

  def find_duplicate_entry_in_shifts(prefix) do
    shifts = Settings.list_shifts(prefix)

    duplicates = Enum.filter(shifts, fn sh ->
    Enum.count(shifts, &(&1.code == sh.code)) > 1
    end)

    header = [["id", "code", "active"]]

    body =
      Enum.map(duplicates, fn d ->
        [d.id, d.code, d.active]
      end)

    final_report = header ++ body
    final_report

  end

  def find_duplicate_entry_in_sites(prefix) do
    sites = AssetConfig.list_sites(prefix)

    duplicates = Enum.filter(sites, fn s ->
    Enum.count(sites, &(&1.site_code == s.site_code)) > 1
    end)

    header = [["id", "site_code", "active"]]

    body =
      Enum.map(duplicates, fn d ->
        [d.id, d.site_code, d.active]
      end)

    final_report = header ++ body
    final_report
  end

  def find_duplicate_entry_in_locations(prefix) do
    locations = AssetConfig.list_locations(prefix)

    duplicates = Enum.filter(locations, fn l ->
      Enum.count(locations, &(&1.location_code == l.location_code)) > 1
      end)

    header = [["id", "location_code", "active"]]

    body =
      Enum.map(duplicates, fn d ->
        [d.id, d.location_code, d.active]
      end)

    final_report = header ++ body
    final_report
  end

  def find_duplicate_entry_in_equipments(prefix) do
    equipments = AssetConfig.list_equipments(prefix)

    duplicates = Enum.filter(equipments, fn l ->
      Enum.count(equipments, &(&1.equipment_code == l.equipment_code)) > 1
      end)

    header = [["id", "equipment_code", "active"]]

    body =
      Enum.map(duplicates, fn d ->
        [d.id, d.equipment_code, d.active]
      end)

    final_report = header ++ body
    final_report
  end

  def find_duplicate_entry_in_uoms(prefix) do
    uoms = Inventory.list_uoms(prefix)

    duplicates = Enum.filter(uoms, fn l ->
      Enum.count(uoms, &(&1.name == l.name)) > 1
      end)

    header = [["id", "name", "active"]]

    body =
      Enum.map(duplicates, fn d ->
        [d.id, d.name, d.active]
      end)

    final_report = header ++ body
    final_report
  end

  def download_duplicate_values_based_on_table_name(table_name, prefix) do
    case table_name do
      "sites" -> find_duplicate_entry_in_sites(prefix)
      "designations" -> find_duplicate_entries_in_designations(prefix)
      "roles" -> find_duplicate_entry_in_roles(prefix)
      "shifts" -> find_duplicate_entry_in_shifts(prefix)
      "locations" -> find_duplicate_entry_in_locations(prefix)
      "equipments" ->  find_duplicate_entry_in_equipments(prefix)
      "uoms" -> find_duplicate_entry_in_uoms(prefix)
    end
  end
end
