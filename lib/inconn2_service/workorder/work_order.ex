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
    field :start_time, :time
    field :completed_date, :date
    field :completed_time, :time
    field :status, :string
    field :workorder_template_id, :integer
    field :workorder_schedule_id, :integer
    field :work_request_id, :integer
    field :workpermit_required, :boolean, default: false
    field :workpermit_required_from, {:array, :integer}, default: []
    field :workpermit_obtained, {:array, :integer}, default: []
    field :loto_required, :boolean, default: false
    field :loto_approval_from_user_id, :integer
    field :is_loto_obtained, :boolean
    field :pre_check_required, :boolean, default: false
    field :precheck_completed, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(work_order, attrs) do
    work_order
    |> cast(attrs, [:site_id, :asset_id, :user_id, :is_self_assigned, :type, :created_date, :created_time, :assigned_date, :assigned_time,
                    :scheduled_date, :scheduled_time, :start_date, :start_time, :completed_date, :completed_time,
                    :status, :workorder_template_id, :workorder_schedule_id, :work_request_id, :workpermit_required, :loto_required, :pre_check_required,
                    :workpermit_required_from, :workpermit_obtained, :loto_approval_from_user_id, :is_loto_obtained, :precheck_completed])
    |> validate_required([:asset_id, :type, :scheduled_date, :scheduled_time, :workorder_template_id])
    |> validate_inclusion(:type, ["PRV", "BRK"])
    |> validate_start_date_time()
    # |> validate_start_date()
    # |> validate_start_time()
    |> validate_date_order()
    |> validate_time_order()
    |> validate_inclusion(:status, ["cr", "as", "wp", "wpp", "wpa", "lta", "ltp", "ltl", "ip", "cp", "ltr", "cn", "hl"])
    |> validate_based_on_type()
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
  # defp validate_start_date(cs) do
  #   scheduled_date = get_field(cs, :scheduled_date)
  #   start_date = get_field(cs, :start_date)
  #   if start_date != nil do
  #     case Date.compare(scheduled_date, start_date) do
  #       :gt -> add_error(cs, :start_date, "should be greater than scheduled date")
  #       _ -> cs
  #     end
  #   else
  #     cs
  #   end
  # end

  # defp validate_start_time(cs) do
  #   scheduled_time = get_field(cs, :scheduled_time)
  #   start_time = get_field(cs, :start_time)
  #   if start_time != nil do
  #     case Time.compare(scheduled_time, start_time) do
  #       :gt -> add_error(cs, :start_time, "should be greater than scheduled time")
  #       _ -> cs
  #     end
  #   else
  #     cs
  #   end
  # end

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
      "PRV" -> validate_required(cs, :workorder_schedule_id)
      "BRK" -> validate_required(cs, [:site_id, :user_id, :work_request_id])
      _ -> cs
    end
  end

end
