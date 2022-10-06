defmodule Inconn2Service.ReferenceTemplateDownloader do

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Workorder
  alias Inconn2Service.WorkOrderConfig
  alias Inconn2Service.CheckListConfig
  alias Inconn2Service.Staff
  alias Inconn2Service.Assignment
  alias Inconn2Service.Settings
  alias Inconn2Service.Inventory
  alias Inconn2Service.CheckListConfig


  def download_asset_categories(prefix) do
    asset_categories = AssetConfig.list_asset_categories(prefix)

    header = [["id", "reference", "Name", "Asset Type", "Parent Id", "parent reference"]]

    body =
      Enum.map(asset_categories, fn r ->
        [r.id,"", r.name, r.asset_type, r.parent_id, ""]
      end)

    final_report = header ++ body
    final_report
  end

  def download_task_lists(prefix) do
    task_lists = WorkOrderConfig.list_task_lists(prefix)

    header = [["id", "reference", "Name", "Task Ids", "Asset Category Id"]]

    body =
      Enum.map(task_lists, fn r ->
        [r.id, "", r.name, convert_array_of_integers_to_string(r.task_ids), r.asset_category_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_check_lists(prefix) do
    check_lists = CheckListConfig.list_check_lists(prefix)

    header = [["id", "reference", "Name", "Type", "Check Ids"]]

    body =
      Enum.map(check_lists, fn r ->
        [r.id, "", r.name, r.type, convert_array_of_integers_to_string(r.check_ids)]
      end)

      final_report = header ++ body
      final_report
  end

  def download_locations(prefix) do
    locations = AssetConfig.list_active_locations(prefix)

    header = [["id", "reference", "Name", "Description", "Location Code", "Asset Category Id", "Site Id", "Parent Id", "parent reference", "Criticality", "Status"]]

    body =
      Enum.map(locations, fn r ->
        [r.id, "", r.name, r.description, r.location_code, r.asset_category_id, r.site_id, r.criticality, r.status, List.last(r.path), ""]
      end)

    final_report = header ++ body
    final_report
  end

  def download_checks(prefix) do
    check = CheckListConfig.list_checks(%{}, prefix)

    header = [["id", "reference", "Label","Check Type Id"]]

    body =
      Enum.map(check, fn r ->
        [r.id, "", r.label, r.check_type_ids]
      end)

      final_report = header ++ body
      final_report
  end

  def download_tasks(prefix) do
    tasks = WorkOrderConfig.list_tasks(prefix)

    header = [["id", "reference", "Label", "Task Type", "Estimated Time", "Master Task Type Id"]]

    body =
      Enum.map(tasks, fn r ->
        fixed_attributes = [r.id, "", r.label, r.task_type, r.estimated_time, r.master_task_type_id]
        cond do
          r.task_type in ["IO", "IM"] ->
            variable_attributes = Enum.map(r.config["options"], fn x -> "#{x["label"]}:#{x["value"]}" end)
            fixed_attributes ++ variable_attributes
          r.task_type == "MT" ->
            variable_attributes = ["#{r.config["type"]}: #{r.config["UOM"]}"]
            fixed_attributes ++ variable_attributes
          r.task_type == "OB" ->
            variable_attributes = ["#{r.config["min_length"]} - #{r.config["max_length"]}"]
            fixed_attributes ++ variable_attributes
        end
      end)

      final_report = header ++ body
      final_report
  end

  def download_employees(prefix) do
    check = Staff.list_employees(prefix)

    header = [["id", "reference", "First Name", "Last Name", "Employment Start Date", "Employment End Date",
    "Designation", "Designation Id", "Email", "Employee Id", "Landline No", "Mobile No", "Salary", "Create User?", "Reports To",
    "Skills", "Org Unit Id", "Party Id"]]

    body =
      Enum.map(check, fn r ->
        [r.id, "", r.first_name, r.last_name, r.employement_start_date, r.employment_end_date,
        r.designation, r.designation_id, r.email, r.employee_id, r.landline_no, r.mobile_no, r.salary, r.has_login_credentials, r.reports_to,
        convert_array_of_integers_to_string(r.skills), r.org_unit_id, r.party_id]
      end)

      final_report = header ++ body
      final_report
  end

  def download_equipments(prefix) do
    locations = AssetConfig.list_equipments(prefix)

    header = [["id", "reference", "Name", "Equipment Code", "Site Id", "Location Id", "Asset Category Id",
     "Connections In", "Connections Out", "Parent Id", "Parent Reference", "Status", "Criticality", "Tag Name",
     "Description", "Function", "Asset Owned By Id", "Is Movable", "Department", "Asset Manager Id", "Maintenance Manager Id",
     "Created On", "Asset Class"]]

    body =
      Enum.map(locations, fn r ->
        [r.id, "", r.name, r.equipment_code, r.site_id, r.location_id, r.asset_category_id, convert_array_of_integers_to_string(r.connections_in),
         convert_array_of_integers_to_string(r.connections_out), r.parent_id, "", r.status, r.criticality, r.tag_name, r.description, r.function,
         r.asset_owned_by_id, r.is_movable, r.department, r.asset_manager_id, r.maintenance_manager_id, r.created_on, r.asset_class,List.last(r.path), ""]
      end)

    final_report = header ++ body
    IO.inspect(final_report)
    final_report
  end

  defp convert_array_of_integers_to_string(array_of_ids) do
    if array_of_ids != nil do
        array_of_ids
        |> Enum.map(fn id -> to_string(id) end)
        |> Enum.join(",")
    else
      ""
    end
  end


end
