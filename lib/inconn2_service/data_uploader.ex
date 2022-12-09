defmodule Inconn2Service.DataUploader do
  alias Inconn2Service.FileOperations

  @ununiform_schemas ["tasks", "sites"]

  def process_bulk_upload(schema, content, prefix) do
    cond do
      schema not in ["tasks"] ->
        process_uniform_bulk_upload(schema, content, prefix)

      true ->
        process_ununiform_bulk_upload(schema, content, prefix)
    end
  end

  def process_uniform_bulk_upload(schema, content, prefix) do
    data = FileOperations.read_file_without_extra_values(content)

    cond do
      check_for_hierarchical_structure(data) ->
        {flat_part, tricky_part} = Enum.split_with(data, fn d -> d["parent_reference"] == "" end)
        {inserted_flat_data, id_reference} = insert_flat_partin_hierarchy(schema, flat_part, prefix)
        {context, insert_func, _special_fields} = match_schema(schema)
        return_data_for_flat_part = get_return_data(inserted_flat_data, flat_part, context, insert_func, prefix)
        headers = get_headers(List.first(return_data_for_flat_part))
        id_reference |> IO.inspect()
        cond do
          length(return_data_for_flat_part) < length(flat_part) ->
            convert_return_data_to_csv(return_data_for_flat_part, headers, true)
          true ->
            children_to_be_inserted = Enum.map(tricky_part, fn t -> Map.put(t, "parent_id", id_reference[t["parent_reference"]]) end)
            convert_return_data_to_csv(return_data_for_flat_part, headers, true) ++ insert_flat_structure(schema, children_to_be_inserted, prefix, false)
        end

      true ->
        insert_flat_structure(schema, data, prefix)

    end
  end

  # defp insert_hierarchical_structure(schema, data, prefix) do
  #   {context, insert_func} = match_schema(schema)
  # end

  # defp filter_hierarchical(data, "root/existing_parent") do
  #   Stream.reject(data, fn d -> is_nil(d["parent_reference"])  end)
  # end

  # defp filter_hierarchical(data, "non_existing_parent") do
  #   Stream.reject(data, fn d -> !is_nil(d["parent_reference"])  end)
  # end

  # defp get_split_data_with_hierarchy(data) do
  #   {flat_structure, children} = Enum.split(data, fn d -> d["parent_rederence"] == nil end)
  # end

  defp put_id_in_data(_resource, d, "l"), do: d
  defp put_id_in_data(resource, d, "h"), do: Map.put(d, "id", resource.id)

  defp inserting_core(schema, data, prefix, data_type) do
    {context, insert_func, special_fields} = match_schema(schema)
    Stream.transform(update_data(data, special_fields), 0, fn d, acc ->
    case apply(context, insert_func, [d, prefix]) do
      {:ok, resource} -> {[put_id_in_data(resource, d, data_type)], acc + 1}
          _ -> {:halt, acc}
        end
    end)
    |> Enum.to_list()
  end

  defp insert_flat_partin_hierarchy(schema, data, prefix) do
    inserting_core(schema, data, prefix, "h")
    |> seperate_id_from_inserted_data()
  end

  defp seperate_id_from_inserted_data(inserted_data) do
    {
      Enum.map(inserted_data, fn d -> Map.drop(d, ["id"]) end),
      Enum.map(inserted_data, fn d -> {d["reference"], d["id"]} end) |> Enum.into(%{})
    }
  end

  defp insert_flat_structure(schema, data, prefix, header_required \\ true) do
    {context, insert_func, _special_fields} = match_schema(schema)
    inserted = inserting_core(schema, data, prefix, "l")
    return_data = get_return_data(inserted, data, context, insert_func, prefix)
    headers = get_headers(List.first(return_data))
    convert_return_data_to_csv(return_data, headers, header_required)
  end

  defp convert_return_data_to_csv(return_data, headers, header_required) do
    # IO.inspect(headers)
    Stream.map(return_data, fn d ->
      Enum.map(headers, fn h ->
        d[h]
      end)
    end)
    |> Enum.to_list()
    |> add_headers_to_csv_return_format(headers, header_required)
  end

  defp update_data(data, special_fields) do
    Enum.map(data, fn d -> FileOperations.convert_special_keys_to_required_type(special_fields, d) end)
  end

  defp add_headers_to_csv_return_format(return_csv_format, _headers, false), do: return_csv_format
  defp add_headers_to_csv_return_format(return_csv_format, headers, true), do: [headers] ++ return_csv_format

  defp get_return_data(inserted_data, data, context, insert_func, prefix) do
    cond do
      length(inserted_data) < length(data) ->
        not_inserted_list = data -- inserted_data |> IO.inspect()
        d = not_inserted_list |> List.first()
        {:error, cs} = apply(context, insert_func, [d, prefix])
        Ecto.Changeset.traverse_errors(cs, fn {msg, _opts} ->
          msg
        end)
        |> Stream.map(fn {k, v} -> "#{k}:#{v}" end)
        |> Enum.join(",")
        |> put_error(d)
        |> update_list_for_updated_map(not_inserted_list, d)
        |> join_inserted_and_not_inserted(inserted_data)
      true ->
        data
        |> update_status_for_inserted_data()
    end
  end

  defp join_inserted_and_not_inserted(not_inserted_data, inserted_data) do
    update_status_for_inserted_data(inserted_data) ++ not_inserted_data
  end

  defp update_status_for_inserted_data(data) do
    data
    |> Stream.map(fn d -> Map.put(d, "status", "Inserted") end)
    |> Enum.to_list()
  end

  defp get_headers(map), do: Map.keys(map)

  defp update_list_for_updated_map(updated_map, not_inserted_list, old_map) do
    old_map_removed_list = not_inserted_list -- [old_map] |> Stream.map(fn d -> Map.put(d, "status", "Not inserted due to error in previous entry") end) |> Enum.to_list()
    [updated_map] ++ old_map_removed_list
  end

  defp put_error(error, map), do: Map.put(map, "status", error)

  def process_ununiform_bulk_upload(_schema, _content, _prefix) do

  end


  defp check_for_hierarchical_structure(data) do
    List.first(data) |> Map.keys() |> check_for_key("parent_id")
  end

  defp check_for_key(keys, key), do: key in keys

  defp match_schema(schema) do
    case schema do
      "tasks" -> {Inconn2Service.WorkOrderConfig.Task, :create_task}
      "master_task_types" -> {Inconn2Service.WorkOrderConfig, :create_master_task_type, []}
      "asset_categories" -> {Inconn2Service.AssetConfig, :create_asset_category, []}
      "workorder_templates" -> {Inconn2Service.Workorder, :create_workorder_template, []}
      "workorder_schedules" -> {Inconn2Service.Workorder, :create_workorder_schedules, []}
      "checks" -> {Inconn2Service.CheckListConfig, :create_check, []}
      "employees" -> {Inconn2Service.Staff, :create_employee, []}
      "users" -> {Inconn2Service.Staff, :create_user, []}
    end
  end
end
