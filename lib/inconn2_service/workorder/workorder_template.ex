defmodule Inconn2Service.Workorder.WorkorderTemplate do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.AssetCategory

  schema "workorder_templates" do
    belongs_to :asset_category, AssetCategory
    field :name, :string
    field :asset_type, :string
    field :task_list_id, :integer
    field :tasks, {:array, :map}
    field :estimated_time, :integer
    field :scheduled, :boolean
    field :repeat_every, :integer
    field :repeat_unit, :string
    field :applicable_start, :date
    field :applicable_end, :date
    field :time_start, :time
    field :time_end, :time
    field :create_new, :string
    field :max_times, :integer
    field :workorder_prior_time, :integer
    field :workpermit_required, :boolean
    field :workpermit_check_list_id, :integer
    field :loto_required, :boolean
    field :loto_lock_check_list_id, :integer
    field :loto_release_check_list_id, :integer

    timestamps()
  end

  @doc false
  def changeset(workorder_template, attrs) do
    workorder_template
    |> cast(attrs, [:asset_category_id, :name, :task_list_id, :tasks, :estimated_time, :scheduled, :repeat_every, :repeat_unit, :applicable_start, :applicable_end, :time_start, :time_end, :create_new, :max_times, :workorder_prior_time, :workpermit_required, :workpermit_check_list_id, :loto_required, :loto_lock_check_list_id, :loto_release_check_list_id])
    |> validate_required([:asset_category_id, :name, :task_list_id, :tasks, :estimated_time, :scheduled])
    |> validate_scheduled()
    |> validate_time_required()
    |> validate_inclusion(:repeat_unit, ["H", "D", "W", "M", "Y"])
    |> validate_date_order()
    |> validate_time_order()
    |> validate_inclusion(:create_new, ["at", "oc"])
    |> validate_workpermit_required()
    |> validate_loto_required()
  end

  defp validate_scheduled(cs) do
    case get_field(cs, :scheduled) do
      true -> validate_required(cs, [ :repeat_every, :repeat_unit, :applicable_start, :applicable_end, :create_new, :max_times, :workorder_prior_time, :workpermit_required, :loto_required])
      false -> cs
      _ -> cs
    end
  end

  defp validate_time_required(cs) do
    case get_field(cs, :repeat_unit) do
      "H" -> validate_required(cs, [:time_start, :time_end])
       _ -> cs
    end
  end

  defp validate_date_order(cs) do
    start_date = get_field(cs, :applicable_start)
    end_date = get_field(cs, :applicable_end)
    case Date.compare(start_date, end_date) do
      :gt -> add_error(cs, :start_date, "cannot be later than 'end_date'")
      _ -> cs
    end
  end

  defp validate_time_order(cs) do
    start_time = get_field(cs, :time_start)
    end_time = get_field(cs, :time_end)
    if start_time != nil and end_time != nil do
      case Time.compare(start_time, end_time) do
        :gt -> add_error(cs, :time_start, "cannot be later than 'time_end'")
        _ -> cs
      end
    else
      cs
    end
  end

  defp validate_workpermit_required(cs) do
    case get_field(cs, :workpermit_required) do
      true -> validate_required(cs, [:workpermit_check_list_id])
      false -> cs
      _ -> cs
    end
  end

  defp validate_loto_required(cs) do
    case get_field(cs, :loto_required) do
      true -> validate_required(cs, [:loto_lock_check_list_id, :loto_release_check_list_id])
      false -> cs
      _ -> cs
    end
  end

end
