defmodule Inconn2Service.WorkOrderConfig.Task do
  use Ecto.Schema

  import Ecto.Changeset

  schema "tasks" do
    field :label, :string
    field :task_type, :string
    field :config, :map
    field :estimated_time, :integer

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:label, :task_type, :config, :estimated_time])
    |> validate_required([:label, :task_type, :config, :estimated_time])
    |> validate_inclusion(:task_type, ["Inspection_one", "Inspection_many", "Metering", "Observation"])
    |> validate_config()
  end

  def validate_config(changeset) do
    task_type = get_field(changeset, :task_type)
    config = get_field(changeset, :config)
    case task_type do
      "Inspection_one"  ->
            if Map.keys(config) == ["label", "value"] do
              changeset
            else
              add_error(changeset, :config, "Config is invalid")
            end
      "Inspection_many" ->
            if Map.keys(config) == ["label", "value"] do
              changeset
            else
              add_error(changeset, :config, "Config is invalid")
            end
      "Metering" ->
            if Map.keys(config) == ["UOM", "type"] and config["type"] in ["C","A"] do
              changeset
            else
              add_error(changeset, :config, "Config is invalid")
            end
      "Observation" ->
        if Map.keys(config) == ["Observation"] do
          length = String.length(config["Observation"])
          if 10<length and length<100 do
            changeset
          else
            add_error(changeset, :config, "config length is invalid")
          end
        else
          add_error(changeset, :config, "config is invalid")
        end
    end
  end

end
