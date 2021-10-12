defmodule Inconn2Service.ReferenceDataUploader do

  alias Inconn2Service.{AssetConfig, FileLoader}
  alias Inconn2Service.Util.HierarchyManager
  alias Inconn2Service.Repo

  def upload_locations(content, prefix) do
    req_fields = ["id", "action", "reference", "Name", "Description", "Location Code", "Asset Category ID", "Site ID", "Parent ID", "parent reference"]

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
         getter_func,
         insert_func,
         update_func,
         prefix
       ) do
    validate_result =
      case parse_and_choose_records(content, required_fields) do
        {:ok, records} -> records |> validate_actions(context_module, getter_func, prefix)
        {:error, err_msgs} -> {:error, err_msgs}
      end

    case validate_result do
      {:ok, records} ->
        perform_insert(
          records,
          param_mapper,
          context_module,
          insert_func,
          update_func,
          prefix
        )

      {:error, error_messages} ->
        {:error, error_messages}
    end
  end


  # Action perform functions
  defp perform_actions(records, param_mapper, context_module, insert_func, update_func, prefix) do
    Enum.map(records, fn r ->
      {ctrl_map, attrs} =
        Map.split(r, ["id", "active", "reference", "parent reference", "action", "action_valid", "action_error", "db_rec"])

      attrs = param_mapper.(attrs)
      db_rec = Map.get(ctrl_map, "db_rec")

      case Map.get(ctrl_map, "action") do
        "I" ->
          apply(context_module, insert_func, [attrs, prefix])

        "U" ->
          apply(context_module, update_func, [db_rec, attrs, prefix])

        "D" ->
          subtree = HierarchyManager.subtree(db_rec) |> Repo.all(prefix: prefix)
          Enum.map(subtree, fn x ->
                                apply(context_module, update_func, [x, %{"active" => false}, prefix])
                            end)

        "R" ->
          subtree = HierarchyManager.subtree(db_rec) |> Repo.all(prefix: prefix)
          Enum.map(subtree, fn x ->
                                apply(context_module, update_func, [x, %{"active" => true}, prefix])
                            end)
      end
    end)
  end

  defp parse_and_choose_records(content, required_fields) do
    case FileLoader.get_records_as_map_for_csv(content, required_fields) do
      {:ok, map} ->
        records =
          map
          |> filter_empty_actions()
          |> transform_action()
          |> Enum.map(fn r -> fill_id(r) end)
          |> Enum.map(fn r -> fill_parent_id(r) end)

        {:ok, records}

      {:error, messages} ->
        {:error, messages}
    end
  end

  # Input Transformation
  defp filter_empty_actions(records) do
    Enum.filter(records, fn r ->
      act = Map.get(r, "action", "") |> String.trim()
      act_len = String.length(act)
      act_len > 0 and act in ["i", "I", "u", "U", "d", "D", "r", "R"]
    end)
  end

  defp transform_action(records) do
    Enum.map(records, fn r ->
      act = Map.get(r, "action")
      cond do
        act == "i" or act == "I" -> Map.put(r, "action", "I")
        act == "u" or act == "U" -> Map.put(r, "action", "U")
        act == "d" or act == "D" -> Map.put(r, "action", "D")
        act == "r" or act == "R" -> Map.put(r, "action", "R")
      end
    end)
  end

  defp fill_id(record) do
    case Integer.parse(Map.get(record, "id", "")) do
      {num, _} -> Map.put(record, "id", num)
      _ -> Map.put(record, "id", 0)
    end
  end

  defp fill_parent_id(record) do
    case Integer.parse(Map.get(record, "Parent ID", "")) do
      {0, _} -> Map.put(record, "Parent ID", nil)
      {num, _} -> Map.put(record, "Parent ID", num)
      _ -> Map.put(record, "Parent ID", nil)
    end
  end


  # Input validations
  def validate_actions(records, context_mod, getter_func, prefix) do
    records =
      Enum.map(records, fn r ->
        action = Map.get(r, "action")
        validate_action_id(action, r, context_mod, getter_func, prefix)
      end)

    all_valid? =
      Enum.reduce(records, true, fn r, acc ->
        acc and Map.get(r, "action_valid")
      end)

    case all_valid? do
      true ->
        {:ok, records}

      false ->
        err_msgs =
          Enum.reduce(records, [], fn r, acc ->
            err_msg = Map.get(r, "action_error")

            if String.trim(err_msg) == "" do
              acc
            else
              acc ++ [err_msg]
            end
          end)

        {:error, err_msgs}
    end
  end

  # if action is I then id must be 0
  def validate_action_id("I", record, _mod, _func, _prefix) do
    case Map.get(record, "id") do
      0 ->
        Map.put(record, "action_valid", true) |> Map.put("action_error", "")

      x ->
        Map.put(record, "action_valid", false)
        |> Map.put("action_error", "cannot insert record with an id: #{x}")
    end
  end

  # if action is U, D, R then id must be present and valid
  # Set id here and validate for existence and load the structure if action is U, D, R
  def validate_action_id("U", record, mod, func, prefix) do
    case Map.has_key?(record, "Parent ID") do
      true ->
          id = Map.get(record, "id")
          case id do
            0 ->
              Map.put(record, "action_valid", false)
              |> Map.put("action_error", "cannot modify/delete record with out an id")

            _ ->
              record = Map.put(record, "action_valid", true) |> Map.put("action_error", "")
              db_rec = apply(mod, func, [id, prefix])

              case db_rec do
                nil ->
                  Map.put(record, "action_valid", false)
                  |> Map.put("action_error", "cannot modify/delete record with invalid id: #{id}")

                _ ->
                  Map.put(record, "db_rec", db_rec) |> validate_rec_active("U", db_rec.active)
              end
          end
      false ->
        Map.put(record, "action_valid", false)
        |> Map.put("action_error", "cannot modify record with hierarchy")
    end
  end

  def validate_action_id(action, record, mod, func, prefix)
      when action in ["D", "R"] do
    id = Map.get(record, "id")

    case id do
      0 ->
        Map.put(record, "action_valid", false)
        |> Map.put("action_error", "cannot modify/delete record with out an id")

      _ ->
        record = Map.put(record, "action_valid", true) |> Map.put("action_error", "")
        db_rec = apply(mod, func, [id, prefix])

        case db_rec do
          nil ->
            Map.put(record, "action_valid", false)
            |> Map.put("action_error", "cannot modify/delete record with invalid id: #{id}")

          _ ->
            Map.put(record, "db_rec", db_rec) |> validate_rec_active(action, db_rec.active)
        end
    end
  end

  # if action is U then active of db record must be true
  def validate_rec_active(record, "U", true), do: record

  def validate_rec_active(record, "U", false) do
    id = Map.get(record, "id")

    Map.put(record, "action_valid", false)
    |> Map.put("action_error", "cannot Update record with invalid state, id: #{id}")
  end

  # if action is D then active of db record must be true
  def validate_rec_active(record, "D", true), do: record

  def validate_rec_active(record, "D", false) do
    id = Map.get(record, "id")

    Map.put(record, "action_valid", false)
    |> Map.put("action_error", "cannot Delete record with invalid state, id: #{id}")
  end

  # if action is R then active of db record must be false
  def validate_rec_active(record, "R", false), do: record

  def validate_rec_active(record, "R", true) do
    id = Map.get(record, "id")

    Map.put(record, "action_valid", false)
    |> Map.put("action_error", "cannot Resurrect/Undelete record with invalid state, id: #{id}")
  end


  defp perform_insert(records, param_mapper, context_module, insert_func, _update_func, prefix) do
    {processing_list, unprocessed_list} = Enum.split_with(records, fn x -> x["Parent ID"] != nil end)
    processed_list = insert_without_parent_reference(param_mapper, context_module, insert_func, prefix, processing_list)


    {processing_list, unprocessed_list} = Enum.split_with(unprocessed_list, fn x -> x["parent reference"] == nil end)
    processed_list = processed_list ++ insert_without_parent_reference(param_mapper, context_module, insert_func, prefix, processing_list)


    insert_with_parent_reference(param_mapper, context_module, insert_func, prefix, processed_list, unprocessed_list)


  end

  defp insert_without_parent_reference(param_mapper, context_module, insert_func, prefix, processing_list) do
    Enum.map(processing_list, fn r ->
                {_ctrl_map, attrs} =
                  Map.split(r, ["id", "active", "reference", "parent reference", "action", "action_valid", "action_error", "db_rec"])

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
                                r = Map.put(r, "Parent ID", result.parent_id)
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
