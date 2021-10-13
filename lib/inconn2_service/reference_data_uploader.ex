defmodule Inconn2Service.ReferenceDataUploader do

  alias Inconn2Service.{AssetConfig, FileLoader}

  def upload_locations(content, prefix) do
    req_fields = ["id", "reference", "Name", "Description", "Location Code", "Asset Category Id", "Site Id", "Parent Id", "parent reference"]

    upload_content(
      content,
      req_fields,
      &FileLoader.make_locations/1,
      AssetConfig,
      :get_location,
      :create_location,
      :update_location,
      prefix
    )
  end

  # Content upload function
  defp upload_content(
         content,
         required_fields,
         param_mapper,
         context_module,
         _getter_func,
         insert_func,
         _update_func,
         prefix
       ) do
    validate_result =
      case parse_and_choose_records(content, required_fields) do
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

  defp parse_and_choose_records(content, required_fields) do
    case FileLoader.get_records_as_map_for_csv(content, required_fields) do
      {:ok, map} ->
        records =
          map
          |> Enum.map(fn r -> fill_id(r) end)
          |> Enum.map(fn r -> fill_parent_id(r) end)

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
