defmodule Inconn2Service.ReferenceDataUploader do

  alias Inconn2Service.{AssetConfig, FileLoader, WorkOrderConfig, CheckListConfig, Workorder}
  alias Inconn2Service.{Staff, Settings, Assignment, Inventory}

  def upload_locations(content, prefix) do
    req_fields = ["id", "reference", "Name", "Description", "Location Code", "Asset Category Id", "Site Id", "Parent Id", "parent reference"]

    upload_content(
      content,
      req_fields,
      [],
      &FileLoader.make_locations/1,
      AssetConfig,
      :get_location,
      :create_location,
      :update_location,
      prefix
    )
  end

  def upload_asset_categories(content, prefix) do
    IO.inspect("Executing Bulk Upload for Asset Categories")
    req_fields = ["id", "reference", "Name", "Asset Type", "Parent Id", "parent reference"]

    upload_content(
      content,
      req_fields,
      [],
      &FileLoader.make_asset_categories/1,
      AssetConfig,
      :get_asset_category,
      :create_asset_category,
      :update_asset_category,
      prefix
    )
  end

  def upload_equipments(content, prefix) do
    req_fields = ["id", "reference", "Name", "Equipment Code", "Asset Category Id", "Site Id", "Location Id", "Connections In", "Connections Out","Parent Id", "parent reference"]
    special_fields = [{"Connections In", "array_of_integers", []}, {"Connections Out", "array_of_integers", []}]
    upload_content(
      content,
      req_fields,
      special_fields,
      &FileLoader.make_equipments/1,
      AssetConfig,
      :get_equipment,
      :create_equipment,
      :update_equipment,
      prefix
    )
  end

  def upload_task_lists(content, prefix) do
    req_fields = ["id", "reference", "Name", "Task Ids", "Asset Category Id"]
    special_fields = [{"Task Ids", "array_of_integers", []}]
    upload_content(
      content,
      req_fields,
      special_fields,
      &FileLoader.make_task_lists/1,
      WorkOrderConfig,
      :get_task_list,
      :create_task_list,
      :update_task_list,
      prefix
    )
  end

  def upload_checks(content, prefix) do
    req_fields = ["id", "reference", "Label", "Type"]
    upload_content(
      content,
      req_fields,
      [],
      &FileLoader.make_checks/1,
      CheckListConfig,
      :get_check,
      :create_check,
      :update_check,
      prefix
    )
  end

  def upload_check_types(content, prefix) do
    req_fields = ["id", "reference", "Name", "Description"]
    upload_content(
      content,
      req_fields,
      [],
      &FileLoader.make_check_types/1,
      CheckListConfig,
      :get_check_type,
      :create_check_type,
      :update_check_type,
      prefix
    )
  end

  def upload_master_task_types(content, prefix) do
    req_fields = ["id", "reference", "Name", "Description"]
    upload_content(
      content,
      req_fields,
      [],
      &FileLoader.make_check_types/1,
      WorkOrderConfig,
      :get_master_task_type,
      :create_master_task_type,
      :update_master_task_type,
      prefix
    )
  end

  def upload_check_lists(content, prefix) do
    req_fields = ["id", "reference", "Name", "Type", "Check Ids"]
    special_fields = [{"Check Ids", "array_of_integers", []}]

     upload_content(
       content,
       req_fields,
       special_fields,
       &FileLoader.make_check_lists/1,
       CheckListConfig,
       :get_check_list,
       :create_check_list,
       :update_check_list,
       prefix
     )
  end

  def upload_uoms(content, prefix) do
    req_fields = ["id", "reference", "Name", "Symbol"]
    # special_fields = [{"Check Ids", "array_of_integers", []}]

     upload_content(
       content,
       req_fields,
       [],
       &FileLoader.make_uoms/1,
       Inventory,
       :get_uom,
       :create_uom,
       :update_uom,
       prefix
     )
  end


  def upload_items(content, prefix) do
    req_fields = ["id", "reference", "Name", "Part No", "Asset Category Ids", "Consume Unit Uom Id", "Inventory Unit Uom Id",
    "Purchase Unit Uom Id", "Min Order Quantity", "Reorder Quantity", "Type", "Aisle", "Row", "Bin"]
    special_fields = [{"Asset Category Ids", "array_of_integers", []}]

     upload_content(
       content,
       req_fields,
       special_fields,
       &FileLoader.make_items/1,
       Inventory,
       :get_item,
       :create_item,
       :update_item,
       prefix
     )
  end


  def upload_workorder_templates(content, prefix) do
    req_fields = ["id", "reference", "Name", "Asset Category Id", "Asset Type", "Task List Id", "Tasks",
    "Estimated Time", "Scheduled", "Repeat Every", "Repeat Unit", "Applicable Start", "Applicable End",
    "Time Start", "Time End", "Create New", "Max Times", "Work Order Prior Time", "Work Permit Required",
    "Work Permit Check List Id", "Loto Required", "Loto Lock Check List Id", "Loto Release Check List Id"]

    special_fields = [{"Tasks", "integer_array_tuples_with_index", []}, {"Scheduled", "boolean", []},
                      {"Work Permit Required", "boolean", []}, {"Loto Required", "boolean", []},
                      {"Applicable Start", "date", []}, {"Applicable End", "date", []}]

    upload_content(
      content,
      req_fields,
      special_fields,
      &FileLoader.make_workorder_templates/1,
      Workorder,
      :get_workorder_template,
      :create_workorder_template,
      :update_workorder_template,
      prefix
    )
  end

  def upload_sites(content, prefix) do
    req_fields = ["id", "reference", "Name", "Description", "Branch", "Area", "Latitude", "Longitude", "Fencing Radius", "Site Code", "Time Zone", "Party Id",
    "Address Line 1", "Address Line 2", "City", "State", "Country", "Postcode", "Contact First Name", "Contact Last Name", "Contact Designation",
    "Contact Email", "Contact Mobile", "Contact Land Line"]

    special_fields = [{"Address", "map_out_of_existing_options", [{"Address Line 1", "address_line1"}, {"Address Line 2", "address_line2"}, {"City", "city"}, {"State", "state"}, {"Country", "country"}, {"Postcode", "postcode"}]},
                      {"Contact", "map_out_of_existing_options", [{"Contact First Name", "first_name"}, {"Contact Last Name", "last_name"}, {"Contact Designation", "designation"}, {"Contact Email", "email"}, {"Contact Mobile", "mobile"}, {"Contact Land Line", "land_line"}]}]

    upload_content(
      content,
      req_fields,
      special_fields,
      &FileLoader.make_sites/1,
      AssetConfig,
      :get_site,
      :create_site,
      :update_site,
      prefix
    )
  end

  def upload_workorder_schedules(content, prefix) do
    req_fields = ["id", "reference", "Workorder Template Id", "Asset Id", "Asset Type", "Holidays",
                  "First Occurrence Date", "First Occurrence Time", "Next Occurrence Date", "Next Occurrence Time"]

    special_fields = [{"Holidays", "array_of_integers", []}, {"First Occurrence Date", "date", []}]

    upload_content(
      content,
      req_fields,
      special_fields,
      &FileLoader.make_workorder_schedules/1,
      Workorder,
      :get_workorder_schedule,
      :create_workorder_schedule,
      :update_workorder_schedule,
      prefix
    )
  end

  def upload_employees(content, prefix) do
    req_fields = ["id", "reference", "First Name", "Last Name", "Employment Start Date", "Employment End Date",
                  "Designation", "Email", "Employee Id", "Landline No", "Mobile No", "Salary", "Create User?", "Reports To",
                  "Skills", "Org Unit Id", "Party Id"]

    special_fields = [{"Skills", "array_of_integers", []}, {"Create User?", "boolean", []},
                      {"Employment Start Date", "date", []}, {"Employment End Date", "date", []}]

    upload_content(
      content,
      req_fields,
      special_fields,
      &FileLoader.make_employees/1,
      Staff,
      :get_employee,
      :create_employee,
      :update_employee,
      prefix
    )
  end

  def upload_org_units(content, prefix) do
    req_fields = ["id", "reference", "Name", "Party Id", "Parent Id", "parent reference"]

    upload_content(
      content,
      req_fields,
      [],
      &FileLoader.make_org_units/1,
      Staff,
      :get_org_unit,
      :create_org_unit,
      :update_org_unit,
      prefix
    )
  end

  def upload_tasks(content, prefix) do
    req_fields = ["id", "reference", "Label", "Task Type", "Estimated Time"]
    special_fields = [{"Config", "random_json_key_value", []}]

    upload_content(
      content,
      req_fields,
      special_fields,
      &FileLoader.make_tasks/1,
      WorkOrderConfig,
      :get_task,
      :create_task,
      :update_task,
      prefix
    )
  end

  def upload_shifts(content, prefix) do
    req_fields = ["id", "reference", "Name", "Start Time", "End Time", "Applicable Days", "Start Date", "Site Id"]
    special_fields = [{"Applicable Days", "array_of_integers", []}, {"Applicable Days", "date", []}, {"Start Date", "date", []}]

    upload_content(
      content,
      req_fields,
      special_fields,
      &FileLoader.make_shifts/1,
      Settings,
      :get_shift,
      :create_shift,
      :update_shift,
      prefix
    )
  end

  def upload_bankholidays(content, prefix) do
    req_fields = ["id", "reference", "Name", "Start Date", "End Date", "Site Id"]
    special_fields = [{"Start Date", "date", []}, {"End Date", "date", []}]
    upload_content(
      content,
      req_fields,
      special_fields,
      &FileLoader.make_bankholidays/1,
      Settings,
      :get_holiday,
      :create_holiday,
      :update_holiday,
      prefix
    )
  end

  def upload_employee_rosters(content, prefix) do
    req_fields = ["id", "reference", "Employee Id", "Site Id", "Shift Id", "Start Date", "End Date"]
    special_fields = [{"Start Date", "date", []}, {"End Date", "date", []}]

    upload_content(
      content,
      req_fields,
      special_fields,
      &FileLoader.make_employee_rosters/1,
      Assignment,
      :get_employee_roster,
      :create_employee_roster,
      :update_employee_roster,
      prefix
    )

  end

  # Content upload function
  defp upload_content(
         content,
         required_fields,
         special_fields,
         param_mapper,
         context_module,
         _getter_func,
         insert_func,
         _update_func,
         prefix
       ) do

    IO.inspect("Inside Upload Content Function")
    validate_result =
      case parse_and_choose_records(content, required_fields, special_fields) do
        {:ok, records} -> {:ok, records}
        {:error, err_msgs} -> {:error, err_msgs}
      end

    # IO.inspect(validate_result)

    case validate_result do
      {:ok, records} ->
            if Map.has_key?(List.first(records), "Parent Id") do
              perform_insert_with_parents(records, param_mapper, context_module, insert_func, prefix)
            else
              perform_insert_without_parents(records, param_mapper, context_module, insert_func, prefix)
            end

      {:error, error_messages} ->
        {:error, error_messages}
    end
  end



  # Action perform functions
  defp perform_insert_without_parents(records, param_mapper, context_module, insert_func, prefix) do
    IO.inspect("Here are the records")
    Enum.map(records, fn r ->
      {_ctrl_map, attrs} =
        Map.split(r, ["id", "active", "reference", "parent reference", "action", "action_valid", "action_error"])
      # IO.inspect(attrs)
      attrs = param_mapper.(attrs)
      apply(context_module, insert_func, [attrs, prefix]) |> IO.inspect()

    end)
  end

  def fill_parent_id_and_reference(records) do
    case Map.has_key?(List.first(records),  "Parent Id") do
      true ->
        records
        |> Enum.map(fn r -> fill_parent_id(r) end)
        |> Enum.map(fn r -> fill_parent_reference(r)  end)
      _ ->
        records
    end
  end

  defp parse_and_choose_records(content, required_fields, array_fields) do
    case FileLoader.get_records_as_map_for_csv(content, required_fields, array_fields) do
      {:ok, map} ->
        records =
          map
          |> Enum.map(fn r -> fill_id(r) end)
          |> Enum.map(fn r -> fill_reference(r) end)
          |> fill_parent_id_and_reference()


        # IO.inspect(records)
        {:ok, records}

      {:error, messages} ->
        {:error, messages}
    end
  end

  defp fill_id(record) do
    case Integer.parse(Map.get(record, "id", "")) do
      {num, _} -> Map.put(record, "id", num)
      _ -> Map.put(record, "id", 0)
    end
  end

  defp fill_parent_id(record) do
    case Integer.parse(Map.get(record, "Parent Id", "")) do
      {0, _} -> Map.put(record, "Parent Id", nil)
      {num, _} -> Map.put(record, "Parent Id", num)
      _ -> Map.put(record, "Parent Id", nil)
    end
  end

  defp fill_reference(record) do
    case Integer.parse(Map.get(record, "reference", "")) do
      {0, _} -> Map.put(record, "reference", nil)
      {num, _} -> Map.put(record, "reference", num)
      _ -> Map.put(record, "reference", nil)
    end
  end

  defp fill_parent_reference(record) do
    case Integer.parse(Map.get(record, "parent reference", "")) do
      {0, _} -> Map.put(record, "parent reference", nil)
      {num, _} -> Map.put(record, "parent reference", num)
      _ -> Map.put(record, "parent reference", nil)
    end
  end



  defp perform_insert_with_parents(records, param_mapper, context_module, insert_func, prefix) do
    {processing_list, unprocessed_list} = Enum.split_with(records, fn x -> x["Parent Id"] != nil end)
    # IO.inspect(processing_list)
    # IO.inspect(unprocessed_list)
    processed_list = insert_without_parent_reference(param_mapper, context_module, insert_func, prefix, processing_list)

    {processing_list, unprocessed_list} = Enum.split_with(unprocessed_list, fn x -> x["parent reference"] == nil end)
    processed_list = processed_list ++ insert_without_parent_reference(param_mapper, context_module, insert_func, prefix, processing_list)

    insert_with_parent_reference(param_mapper, context_module, insert_func, prefix, processed_list, unprocessed_list)


  end

  defp insert_without_parent_reference(param_mapper, context_module, insert_func, prefix, processing_list) do
    Enum.map(processing_list, fn r ->
                {_ctrl_map, attrs} =
                  Map.split(r, ["id", "active", "reference", "parent reference", "action", "action_valid", "action_error"])

                attrs = param_mapper.(attrs)

                result = apply(context_module, insert_func, [attrs, prefix])
                case result do
                  {:ok, result} -> Map.put(r, "id", result.id)
                  {:error, cs} ->
                    IO.inspect(cs)
                    r
                end

              end)
  end

  defp insert_with_parent_reference(param_mapper, context_module, insert_func, prefix, processed_list, processing_list) do
    list = Enum.map(processing_list, fn r ->
                            {ctrl_map, attrs} =
                              Map.split(r, ["id", "active", "reference", "parent reference", "action", "action_valid", "action_error", "db_rec"])

                            attrs = param_mapper.(attrs)
                            {processed, _} = Enum.split_with(processed_list, fn x -> x["reference"] == ctrl_map["parent reference"] end)
                            processed = List.first(processed)

                            attrs = Map.put(attrs, "parent_id", processed["id"])

                            if attrs["parent_id"] != nil do
                                result = apply(context_module, insert_func, [attrs, prefix])
                                case result do
                                  {:ok, result} ->
                                      r = Map.put(r, "Parent Id", result.parent_id)
                                      Map.put(r, "id", result.id)
                                  {:error, cs} ->
                                      IO.inspect(cs)
                                      r
                                end

                            end

                          end)

    list = Enum.filter(list, fn x -> x != nil end)

    processed_list = processed_list ++ list
    list_reference = Enum.map(list, fn x -> x["reference"] end)
    processing_list = Enum.filter(processing_list, fn x -> x["reference"] not in list_reference end)

    if processing_list != [] do
      insert_with_parent_reference(param_mapper, context_module, insert_func, prefix, processed_list, processing_list)
    end
  end
end
