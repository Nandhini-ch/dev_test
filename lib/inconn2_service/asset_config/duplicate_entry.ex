defmodule Inconn2Service.AssetConfig.DuplicateEntry do
  alias Inconn2Service.Repo
  import Ecto.Query, warn: false
  alias Inconn2Service.Staff.Designation
  alias Inconn2Service.Staff.Role
  alias Inconn2Service.Settings.Shift

  def find_duplicate_entry_in_designations(prefix) do
    query =
      from d in Designation,
      where: d.active == true,
      group_by: d.name,
      having: count(d.id) > 1

    result = Repo.all(query, prefix: prefix)

    header = [["id", "Name", "active"]]

    body =
      Enum.map(result, fn d ->
        [d.id, d.name, d.active]
      end)

    final_report = header ++ body
    final_report
  end

  def find_duplicate_entry_in_roles(prefix) do
    query =
      from r in Role,
      where: r.active == true,
      group_by: r.name,
      having: count(r.id) > 1

    result = Repo.all(query, prefix: prefix)

    header = [["id", "Name", "active"]]

    body =
      Enum.map(result, fn r ->
        [r.id, r.name, r.active]
      end)

    final_report = header ++ body
    final_report
  end

  def find_duplicate_entry_in_shifts(prefix) do
   query =
      from sh in Shift,
      where: sh.active == true,
      group_by: sh.code,
      having: count(sh.id) > 1

   result = Repo.all(query, prefix: prefix)

  header = [["id", "code", "active"]]

  body =
    Enum.map(result, fn sh ->
      [sh.id, sh.code, sh.active]
    end)

  final_report = header ++ body
  final_report

  end

  def find_duplicate_entry_in_sites(prefix) do
    query =
     from r in Role,
     where: r.active == true,
     group_by: r.name,
     having: count(r.id) > 1

    result = Repo.all(query, prefix: prefix)

    header = [["id", "Name", "active"]]

   body =
    Enum.map(result, fn r ->
      [r.id, r.name, r.active]
    end)

    final_report = header ++ body
    final_report

  end

  def get_duplicate_values_based_on_table_name(table_name, prefix) do
    case table_name do
      "sites" -> find_duplicate_entry_in_sites(prefix)
      "designations" -> find_duplicate_entry_in_designations(prefix)
      "roles" -> find_duplicate_entry_in_roles(prefix)
      "shifts" -> find_duplicate_entry_in_shifts(prefix)
    end
  end

end
