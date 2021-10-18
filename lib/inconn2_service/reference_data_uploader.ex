defmodule Inconn2Service.ReferenceDataUploader do

  alias Inconn2Service.{AssetConfig, FileLoader, WorkOrderConfig, CheckListConfig, Workorder}

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

  def upload_workorder_templates(content, prefix) do
    req_fields = ["id", "reference", "Name", "Asset Category Id", "Asset Type", "Task List Id", "Tasks",
    "Estimated Time", "Scheduled", "Repeat Every", "Repeat Unit", "Applicable Start", "Applicable End",
    "Time Start", "Time End", "Create New", "Max Times", "Work Order Prior Time", "Work Permit Required",
    "Work Permit Check List Id", "Loto Required", "Loto Lock Check List Id", "Loto Release Check List Id"]

    special_fields = [{"Tasks", "integer_array_tuples_with_index", []}, {"Scheduled", "boolean", []}, {"Work Permit Required", "boolean", []}, {"Loto Required", "boolean", []}]

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
    "Address Line 1", "Address Line 2", "City", "State", "Country", "Postcode", "First Name", "Last Name", "Designation",
    "Email", "Mobile", "Land Line"]

    special_fields = [{"Address", "map_out_of_existing_options", ["Address Line 1", "Address Line 2", "City", "State", "Country", "Postcode"]},
                      {"Contact", "map_out_of_existing_options", ["First Name", "Last Name", "Designation", "Email", "Mobile", "Land Line"]}]

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

    special_fields = [{"Holidays", "array_of_integers", []}]

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
    Enum.map(records, fn r ->
      {_ctrl_map, attrs} =
        Map.split(r, ["id", "active", "reference", "parent reference", "action", "action_valid", "action_error"])

      attrs = param_mapper.(attrs)

      apply(context_module, insert_func, [attrs, prefix])

    end)
  end

  defp parse_and_choose_records(content, required_fields, array_fields) do
    case FileLoader.get_records_as_map_for_csv(content, required_fields, array_fields) do
      {:ok, map} ->
        records =
          map
          |> Enum.map(fn r -> fill_id(r) end)
          |> Enum.map(fn r -> fill_parent_id(r) end)
          |> Enum.map(fn r -> fill_reference(r) end)
          |> Enum.map(fn r -> fill_parent_reference(r) end)

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

                {:ok, result} = apply(context_module, insert_func, [attrs, prefix])
                Map.put(r, "id", result.id)

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
                                {:ok, result} = apply(context_module, insert_func, [attrs, prefix])
                                r = Map.put(r, "Parent Id", result.parent_id)
                                Map.put(r, "id", result.id)
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
