defmodule Inconn2Service.WorkOrderConfig.Task do
  use Ecto.Schema

  import Ecto.Changeset
  alias Inconn2Service.WorkOrderConfig.TaskList

  schema "tasks" do
    field :label, :string
    field :task_type, :string
    field :master_task_type_id, :integer
    field :config, :map
    field :estimated_time, :integer
    field :active, :boolean, default: true
    many_to_many(:task_lists, TaskList, join_through: "task_tasklists", on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:label, :task_type, :master_task_type_id, :config, :estimated_time, :active])
    |> validate_required([:label, :task_type, :config, :estimated_time, :master_task_type_id, :active])
    |> validate_inclusion(:task_type, ["IO", "IM", "MT", "OB"])
    |> validate_config()
  end

  def validate_config(changeset) do
    task_type = get_field(changeset, :task_type)
    config = get_field(changeset, :config)
    case task_type do
      "IO"  ->
            if Map.has_key?(config, "options") and length(config["options"]) >= 2 do
              validate_options(changeset, config)
            else
              add_error(changeset, :config, "Config is invalid")
            end
      "IM" ->
            if Map.has_key?(config, "options") and length(config["options"]) >= 2 do
              validate_options(changeset, config)
            else
              add_error(changeset, :config, "Config is invalid")
            end
      "MT" ->
            if (["UOM", "type"] -- Map.keys(config) == []) and config["type"] in ["C","A"] do
              validate_lengths(changeset, config["min_value"], config["max_value"], "min value and max value")
            else
              add_error(changeset, :config, "Config is invalid")
            end
      "OB" ->
            if (["max_length", "min_length"] -- Map.keys(config) == []) do
              validate_lengths(changeset, config["min_length"], config["max_length"], "min length and max length")
            else
              add_error(changeset, :config, "Config is invalid")
            end
        _ ->
            changeset
    end
  end

  defp validate_options(changeset, config) do
    options = config["options"]
    if Kernel.is_list(options) do
      if (false not in Enum.map(options, fn x -> Kernel.is_map(x) end)) and (false not in Enum.map(options, fn x -> x not in options--[x] end)) do
        case validate_unique_labels_and_values(options) and validate_raise_ticket(options) do
          true -> changeset
          false -> add_error(changeset, :config, "config is invalid")
        end
      else
        add_error(changeset, :config, "config is invalid")
      end
    else
      add_error(changeset, :config, "config is invalid")
    end
  end

  defp validate_lengths(changeset, min_length, max_length, msg) do
    if Kernel.is_integer(min_length) and Kernel.is_integer(max_length) do
      if min_length < max_length do
        changeset
      else
        add_error(changeset, :config, "lengths are invalid")
      end
    else
      add_error(changeset, :config, msg <> " should be integer")
    end
  end

  defp validate_unique_labels_and_values(options) do
    validate_unique_labels(options) and validate_unique_values(options)
  end

  defp validate_unique_labels(options) do
    labels = Enum.map(options, fn %{"label" => label} -> label end)
    labels == Enum.uniq(labels)
  end

  defp validate_unique_values(options) do
    values = Enum.map(options, fn %{"value" => value} -> value end)
    values == Enum.uniq(values)
  end

  defp validate_raise_ticket(options) do
    true_list = Stream.map(options, fn r -> r["raise_ticket"] end)
                |> Enum.map(fn r -> is_boolean(r) or is_nil(r) end)

    false not in true_list
  end

end
