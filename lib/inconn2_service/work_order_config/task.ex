defmodule Inconn2Service.WorkOrderConfig.Task do
  use Ecto.Schema

  import Ecto.Changeset

  schema "tasks" do
    field :label, :string
    field :task_type, :string
    field :config, :map
    field :estimated_time, :integer
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:label, :task_type, :config, :estimated_time])
    |> validate_required([:label, :task_type, :config, :estimated_time])
    |> validate_inclusion(:task_type, ["IO", "IM", "MT", "OB"])
    |> validate_config()
  end

  def validate_config(changeset) do
    task_type = get_field(changeset, :task_type)
    config = get_field(changeset, :config)
    case task_type do
      "IO"  ->
            if Map.keys(config) == ["options"] and length(config["options"]) >= 2 do
              validate_options(changeset, config)
            else
              add_error(changeset, :config, "Config is invalid")
            end
      "IM" ->
            if Map.keys(config) == ["options"] and length(config["options"]) >= 2 do
              validate_options(changeset, config)
            else
              add_error(changeset, :config, "Config is invalid")
            end
      "MT" ->
            if Map.keys(config) == ["UOM", "type"] and config["type"] in ["C","A"] do
              changeset
            else
              add_error(changeset, :config, "Config is invalid")
            end
      "OB" ->
            if Map.keys(config) == ["max_length", "min_length"] do
              validate_lengths(changeset, config["min_length"], config["max_length"])
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
        case false not in Enum.map(options, fn x -> Map.keys(x) == ["label", "value"] end) and false not in validate_values_of_map(options) do
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

  defp validate_lengths(changeset, min_length, max_length) do
    if Kernel.is_integer(min_length) and Kernel.is_integer(max_length) do
      if min_length < max_length do
        changeset
      else
        add_error(changeset, :config, "lengths are invalid")
      end
    else
      add_error(changeset, :config, "lengths are invalid")
    end
  end

  defp validate_values_of_map(options) do
    list = Enum.map(options, fn map ->
                        Enum.map(Map.values(map), fn x -> Kernel.is_bitstring(x) end) end)
    List.flatten(list)
  end
end
