defmodule Inconn2Service.Workorder.WorkOrder do
  use Ecto.Schema
  import Ecto.Changeset

  schema "work_orders" do
    field :site_id, :integer
    field :asset_id, :integer
    field :asset_type, :string
    field :user_id, :integer
    field :is_self_assigned, :boolean, default: false
    field :type, :string
    field :created_date, :date
    field :created_time, :time
    field :assigned_date, :date
    field :assigned_time, :time
    field :scheduled_date, :date
    field :scheduled_time, :time
    field :start_date, :date
    field :scheduled_end_date, :date
    field :scheduled_end_time, :time
    field :created_user_id, :integer
    field :start_time, :time
    field :completed_date, :date
    field :completed_time, :time
    field :status, :string
    field :workorder_template_id, :integer
    field :workorder_schedule_id, :integer
    field :work_request_id, :integer
    field :is_workorder_approval_required, :boolean
    field :is_workpermit_required, :boolean
    field :is_workorder_acknowledgement_required, :boolean
    field :workorder_approval_user_id, :integer
    field :workpermit_approval_user_ids, {:array, :integer}, default: []
    field :workpermit_obtained_from_user_ids, {:array, :integer}, default: []
    field :workorder_acknowledgement_user_id, :integer
    field :is_loto_required, :boolean
    field :loto_lock_check_list_id, :integer
    field :loto_release_check_list_id, :integer
    field :pre_check_required, :boolean
    field :precheck_completed, :boolean
    field :is_deactivated, :boolean, null: false, default: false
    field :deactivated_date_time, :naive_datetime
    has_many :workorder_tasks, Inconn2Service.Workorder.WorkorderTask
    field :loto_checker_user_id, :integer
    field :pause_resume_times, {:array, :map}, default: []
    field :is_paused, :boolean, default: false
    field :cost, :float

    timestamps()
  end

  @doc false
  def changeset(work_order, attrs) do
    work_order
    |> cast(attrs, [:site_id, :asset_id, :user_id, :is_self_assigned, :type, :created_date, :created_time,
                    :assigned_date, :assigned_time, :scheduled_date, :scheduled_time, :start_date, :start_time,
                    :completed_date, :completed_time, :created_user_id, :status, :workorder_template_id,
                    :workorder_schedule_id, :work_request_id, :workorder_approval_user_id, :workpermit_approval_user_ids,
                    :workpermit_obtained_from_user_ids, :is_workorder_approval_required, :is_workpermit_required,
                    :is_workorder_acknowledgement_required, :workorder_acknowledgement_user_id, :is_loto_required, :loto_lock_check_list_id,
                    :loto_release_check_list_id, :loto_checker_user_id, :scheduled_end_date, :scheduled_end_time, :is_deactivated, :deactivated_date_time, :pause_resume_times, :is_paused, :pre_check_required, :cost])
    |> validate_required([:asset_id, :type, :scheduled_date, :scheduled_time, :workorder_template_id])
    |> validate_inclusion(:type, ["PRV", "BRK", "TKT", "IOT", "MAN"])
    |> validate_start_date_time()
    # |> validate_start_date()
    # |> validate_start_time()
    |> validate_date_order()
    |> validate_time_order()
    |> validate_inclusion(:status, ["cr", "as", "woap", "woaa", "woar", "wpap", "wp", "wpp", "wpa", "wpr",
                                    "ltlap", "ltla", "ltlp", "prep", "prea", "exec", "execwa", "ltrap", "ltrp","ltra",
                                    "ltlr", "ltrr", "ackp", "acka", "ackr", "ip", "cp", "ltr", "cn", "hl"])
    |> validate_based_on_type()
    |> validate_pause_resume_times()
  end


  def reassign_reschedule_changeset(work_order, attrs) do
    work_order
    |> cast(attrs, [:user_id, :scheduled_date, :scheduled_time])
  end

  defp validate_start_date_time(cs) do
    scheduled_date = get_field(cs, :scheduled_date)
    scheduled_time = get_field(cs, :scheduled_time)
    start_date = get_field(cs, :start_date)
    start_time = get_field(cs, :start_time)
    if start_date != nil and start_time != nil do
      sch_dt = NaiveDateTime.new!(scheduled_date, scheduled_time)
      srt_dt = NaiveDateTime.new!(start_date, start_time)
      case NaiveDateTime.compare(sch_dt, srt_dt) do
        :gt -> add_error(cs, :start_date, "should be greater than scheduled date and time")
          _ -> cs
      end
    else
      cs
    end
  end

  defp validate_date_order(cs) do
    start_date = get_field(cs, :start_date)
    end_date = get_field(cs, :completed_date)
    if start_date != nil and end_date != nil do
      case Date.compare(start_date, end_date) do
        :gt -> add_error(cs, :start_date, "cannot be later than 'completed_date'")
        _ -> cs
      end
    else
      cs
    end
  end

  defp validate_time_order(cs) do
    start_time = get_field(cs, :start_time)
    end_time = get_field(cs, :completed_time)
    if start_time != nil and end_time != nil do
      case Time.compare(start_time, end_time) do
        :gt -> add_error(cs, :start_time, "cannot be later than 'completed_time'")
        _ -> cs
      end
    else
      cs
    end
  end

  defp validate_based_on_type(cs) do
    type = get_field(cs, :type)
    case type do
      "TKT" -> validate_required(cs, [:site_id, :user_id, :work_request_id])
      _ -> cs
    end
  end

  defp validate_pause_resume_times(cs) do
    start_date = get_field(cs, :start_date)
    start_time = get_field(cs, :start_time)
    pause_resume = get_field(cs, :pause_resume_times)
    cond do
      is_nil(start_date) and is_nil(start_time) and length(pause_resume) > 0 ->
        add_error(cs, :pause_resume_times, "workorder must be started first")

      is_list(pause_resume) and length(pause_resume) > 0 ->
        if false in validate_maps_in_pause_resume_times(pause_resume) do
          add_error(cs, :pause_resume_times, "is_invalid")
        else
          cs
        end

      true ->
        cs
    end
  end

  defp validate_maps_in_pause_resume_times(pause_resume) do
    last_map = List.last(pause_resume)
    keys = Enum.map(pause_resume -- [last_map], fn map -> validate_keys_in_pause_resume(map) end)
    keys ++ [validate_keys_in_pause_resume(last_map, :last)]
  end

  defp validate_keys_in_pause_resume(map), do: Map.keys(map) == ["pause", "resume"]
  defp validate_keys_in_pause_resume(map, :last), do: Map.keys(map) == ["pause", "resume"] or (length(Map.keys(map)) == 1 and Map.has_key?(map, "pause"))

end
