defmodule Inconn2Service.Workorder.WorkorderTemplate do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.AssetCategory

  schema "workorder_templates" do
    belongs_to :asset_category, AssetCategory
    field :name, :string
    field :task_list_id, :integer
    field :tasks, {:array, :map}
    field :estimated_time, :integer
    field :scheduled, :string
    field :repeat_every, :integer
    field :repeat_unit, :string
    field :applicable_start, :date
    field :applicable_end, :date
    field :time_start, :time
    field :time_end, :time
    field :create_new, :string
    field :max_times, :integer
    field :workorder_prior_time, :integer

    timestamps()
  end

  @doc false
  def changeset(workorder_template, attrs) do
    workorder_template
    |> cast(attrs, [:asset_category_id, :name, :task_list_id, :tasks, :estimated_time, :scheduled, :repeat_every, :repeat_unit, :applicable_start, :applicable_end, :time_start, :time_end, :create_new, :max_times, :workorder_prior_time])
    |> validate_required([:asset_category_id, :name, :task_list_id, :tasks, :estimated_time, :scheduled])
    |> validate_inclusion(:scheduled, ["Y", "N"])
    |> validate_scheduled()
    |> validate_inclusion(:repeat_unit, ["H", "D", "M", "Y"])
    |> validate_date_order()
    |> validate_time_order()
    |> validate_inclusion(:create_new, ["auto", "on completion"])
  end

  defp validate_scheduled(cs) do
    case get_field(cs, :scheduled) do
      "Y" -> validate_required(cs, [ :repeat_every, :repeat_unit, :applicable_start, :applicable_end, :time_start, :time_end, :create_new, :max_times, :workorder_prior_time])
      "N" -> cs
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
    case Time.compare(start_time, end_time) do
      :gt -> add_error(cs, :time_start, "cannot be later than 'time_end'")
      _ -> cs
    end
  end

end
