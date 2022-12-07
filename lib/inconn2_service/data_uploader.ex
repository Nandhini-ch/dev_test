defmodule Inconn2Service.DataUploader do
  alias Inconn2Service.FileOperations

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
        IO.inspect("Hierarchical Structure")

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

  defp insert_flat_structure(schema, data, prefix) do
    {context, insert_func} = match_schema(schema)
    inserted =
      Stream.transform(data, 0, fn d, acc ->
        case apply(context, insert_func, [d, prefix]) do
          {:ok, _resource} -> {[d], acc + 1}
          _ -> {:halt, acc}
        end
      end)
      |> Enum.to_list()
    return_data = get_return_data(inserted, data, context, insert_func, prefix)
    headers = get_headers(List.first(return_data))
    convert_return_data_to_csv(return_data, headers)
  end

  defp convert_return_data_to_csv(return_data, headers) do
    IO.inspect(headers)
    Stream.map(return_data, fn d ->
      Enum.map(headers, fn h ->
        d[h]
      end)
    end)
    |> Enum.to_list()
    |> add_headers_to_csv_return_format(headers)
  end

  defp add_headers_to_csv_return_format(return_csv_format, headers), do: [headers] ++ return_csv_format

  defp get_return_data(inserted_data, data, context, insert_func, prefix) do
    cond do
      length(inserted_data) < length(data) ->
        not_inserted_list = data -- inserted_data
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
      "master_task_types" -> {Inconn2Service.WorkOrderConfig, :create_master_task_type}
    end
  end
end
