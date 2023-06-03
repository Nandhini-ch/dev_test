defmodule Inconn2Service.Workorder.WorkorderTemplate do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.AssetCategory

  schema "workorder_templates" do
    belongs_to :asset_category, AssetCategory
    field :name, :string
    field :description, :string
    field :asset_type, :string
    field :task_list_id, :integer
    field :estimated_time, :integer
    field :scheduled, :boolean, default: false
    field :breakdown, :boolean, default: false
    field :audit, :boolean, default: false
    field :adhoc, :boolean, default: false
    field :movable, :boolean, default: false
    field :amc, :boolean, default: false
    field :repeat_every, :integer
    field :repeat_unit, :string
    field :applicable_start, :date
    field :applicable_end, :date
    field :time_start, :time
    field :time_end, :time
    field :create_new, :string
    field :max_times, :integer
    field :tools, {:array, :map}, default: []
    field :spares, {:array, :map}, default: []
    field :consumables, {:array, :map}, default: []
    field :parts, {:array, :map}, default: []
    field :measuring_instruments, {:array, :map}, default: []
    field :workorder_prior_time, :integer
    field :is_precheck_required, :boolean, default: false
    field :precheck_list_id, :integer
    field :is_workpermit_required, :boolean, default: false
    field :is_workorder_approval_required, :boolean, default: false
    field :is_workorder_acknowledgement_required, :boolean, default: false
    field :workpermit_check_list_id, :integer
    field :is_loto_required, :boolean, default: false
    field :loto_lock_check_list_id, :integer
    field :loto_release_check_list_id, :integer
    field :active, :boolean, default: true
    field :is_materials_required, :boolean, default: false
    field :materials, {:array, :map}, default: []
    field :is_manpower_required, :boolean, default: false
    field :manpower, {:array, :map}, default: []

    timestamps()
  end

  @doc false
  def changeset(workorder_template, attrs) do
    workorder_template
    |> cast(attrs, [:asset_category_id, :name, :description, :task_list_id, :estimated_time,
                    :scheduled, :repeat_every, :repeat_unit, :applicable_start, :applicable_end,
                    :time_start, :time_end, :create_new, :max_times, :tools, :spares, :consumables,
                    :workorder_prior_time, :is_workpermit_required, :is_workorder_approval_required,
                    :workpermit_check_list_id, :is_loto_required, :loto_lock_check_list_id,
                    :loto_release_check_list_id, :is_workorder_acknowledgement_required, :breakdown,
                    :audit, :adhoc, :amc, :movable, :is_precheck_required, :precheck_list_id, :is_materials_required,
                    :is_manpower_required, :materials, :manpower, :parts, :measuring_instruments, :active])
    |> validate_required([:asset_category_id, :name, :task_list_id, :estimated_time, :scheduled])
    |> validate_scheduled()
    |> validate_time_required()
    |> validate_inclusion(:repeat_unit, ["H", "D", "W", "M", "Y"])
    |> validate_date_order()
    |> validate_time_order()
    |> validate_inclusion(:create_new, ["at", "oc"])
    |> validate_workpermit_required()
    |> validate_loto_required()
    |> validate_materials()
    |> validate_manpower()
    |> validate_inventory_items(:tools)
    |> validate_inventory_items(:spares)
    |> validate_inventory_items(:consumables)
    |> validate_inventory_items(:parts)
    |> validate_inventory_items(:measuring_instruments)

  end

  defp validate_scheduled(cs) do
    case get_field(cs, :scheduled) do
      true -> validate_required(cs, [ :repeat_every, :repeat_unit, :applicable_start, :applicable_end, :create_new, :max_times, :workorder_prior_time, :is_workpermit_required, :is_loto_required])
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
    if start_date != nil and end_date != nil do
      case Date.compare(start_date, end_date) do
        :gt -> add_error(cs, :start_date, "cannot be later than 'end_date'")
        _ -> cs
      end
    else
      cs
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
    case get_field(cs, :is_workpermit_required) do
      true -> validate_required(cs, [:workpermit_check_list_id])
      false -> cs
      _ -> cs
    end
  end

  defp validate_loto_required(cs) do
    case get_field(cs, :is_loto_required) do
      true -> validate_required(cs, [:loto_lock_check_list_id, :loto_release_check_list_id])
      false -> cs
      _ -> cs
    end
  end

  defp validate_inventory_items(cs, item_type) do
    items = get_field(cs, item_type)
    cond do
      length(items) == 0 or validate_inner_keys_in_list_of_maps(items, ["item_id", "quantity"]) ->
        cs
      true ->
        add_error(cs, item_type, "keys are invalid")
    end
  end

  defp validate_materials(cs) do
    materials = get_field(cs, :materials)
    cond do
      length(materials) == 0 or validate_inner_keys_in_list_of_maps(materials, ["cost", "item", "quantity"]) ->
        cs
      true ->
        add_error(cs, :materials, "keys are invalid")
    end
  end

  defp validate_manpower(cs) do
    manpower = get_field(cs, :manpower)
    cond do
      length(manpower) == 0 or validate_inner_keys_in_list_of_maps(manpower, ["cost", "count", "description"]) ->
        cs
      true ->
        add_error(cs, :manpower, "keys are invalid")
    end
  end

  defp validate_inner_keys_in_list_of_maps(list, inner_keys) do
    false not in Enum.map(list, fn m -> Map.keys(m) == inner_keys end)
  end

end
