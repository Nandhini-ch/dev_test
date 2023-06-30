defmodule Inconn2Service.Common do
  @moduledoc """
  The Common context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Inconn2Service.Repo
  alias Inconn2Service.Common.Timezone
  alias Inconn2Service.Prompt
  alias Inconn2Service.Prompt.UserAlertNotification
  alias Inconn2Service.Common.PublicUom

  def list_timezones do
    from(t in Timezone, order_by: [asc: t.utc_offset_seconds])
    |> Repo.all()
  end

  def search_timezones(city_text) do
    if String.length(city_text) < 3 do
      []
    else
      search_text = city_text <> "%"

      from(t in Timezone, where: ilike(t.city, ^search_text), order_by: t.city)
      |> Repo.all()
    end
  end

  def get_timezone!(id), do: Repo.get!(Timezone, id)

  def create_timezone(attrs \\ %{}) do
    %Timezone{}
    |> Timezone.changeset(attrs)
    |> Repo.insert()
  end

  def update_timezone(%Timezone{} = timezone, attrs) do
    timezone
    |> Timezone.changeset(attrs)
    |> Repo.update()
  end

  def delete_timezone(%Timezone{} = timezone) do
    Repo.delete(timezone)
  end

  def change_timezone(%Timezone{} = timezone, attrs \\ %{}) do
    Timezone.changeset(timezone, attrs)
  end

  def shift_to_utc(date, time, zone) do
    {:ok, ndt} = NaiveDateTime.new(date, time)
    {:ok, dt} = DateTime.from_naive(ndt, zone)
    DateTime.shift_zone(dt, "Etc/UTC", Tzdata.TimeZoneDatabase)
  end

  def shift_to_utc(date_time, zone) do
    {:ok, dt} = DateTime.from_naive(date_time, zone)
    DateTime.shift_zone(dt, "Etc/UTC", Tzdata.TimeZoneDatabase)
  end

  def shift_to_utc(date, time, zone, before_seconds) do
    {:ok, ndt} = NaiveDateTime.new(date, time)
    {:ok, dt} = DateTime.from_naive(ndt, zone)
    DateTime.add(dt, -1 * before_seconds, :second, Tzdata.TimeZoneDatabase)
    |> DateTime.shift_zone!("Etc/UTC", Tzdata.TimeZoneDatabase)
  end

  def build_timezone_db() do
    Tzdata.canonical_zone_list()
    |> Enum.reduce([], &make_tzmap/2)
    |> Enum.map(fn entry -> create_timezone(entry) end)
  end

  defp make_tzmap(zone, tzmaplist) do
    {off_text, off_secs} = calculate_utc_offset(zone)

    case String.split(zone, "/") do
      [continent | [city]] ->
        add_tz_entry(tzmaplist, zone, continent, "", city, off_text, off_secs)

      [continent | [state | [city]]] ->
        add_tz_entry(tzmaplist, zone, continent, state, city, off_text, off_secs)

      _ ->
        tzmaplist
    end
  end

  defp add_tz_entry(tzmaplist, zone, continent, state, city, off_text, off_secs) do
    [
      %{
        continent: continent,
        label: zone,
        state: state,
        city: String.replace(city, "_", " "),
        utc_offset_text: off_text,
        utc_offset_seconds: off_secs
      }
      | tzmaplist
    ]
  end

  defp calculate_utc_offset(zone) do
    {:ok, pl} = Tzdata.periods(zone)

    [period_selected | []] =
      Enum.filter(pl, fn p -> p.until.utc == :max end)
      |> Enum.take(1)

    utc_offset = Map.get(period_selected, :utc_off)

    if utc_offset != nil do
      {make_utc_offset_string(period_selected.utc_off), utc_offset}
    else
      IO.puts("#{zone} : #{inspect(period_selected)}")
    end
  end

  defp make_utc_offset_string(seconds) do
    {sign, secs} =
      case seconds < 0 do
        true -> {"-", seconds * -1}
        false -> {"+", seconds}
      end

    m = div(secs, 60)
    hours = div(m, 60)
    mins = rem(m, 60)

    str_mins =
      case mins < 10 do
        true -> "0" <> to_string(mins)
        false -> to_string(mins)
      end

    "UTC" <> sign <> to_string(hours) <> ":" <> str_mins
  end

  alias Inconn2Service.Common.WorkScheduler
  alias Inconn2Service.Workorder.WorkorderSchedule

  def list_works_chedulers do
    Repo.all(WorkScheduler)
  end

  def get_work_scheduler!(id), do: Repo.get!(WorkScheduler, id)

  def calculate_utc_datetime(cs) do
    workorder_schedule_id = get_field(cs, :workorder_schedule_id)
    prefix = get_field(cs, :prefix)
    zone = get_field(cs, :zone)
    workorder_schedule = Repo.get!(WorkorderSchedule, workorder_schedule_id, prefix: prefix) |> Repo.preload(:workorder_template)
    before_seconds = workorder_schedule.workorder_template.workorder_prior_time * 60
    date = workorder_schedule.next_occurrence_date
    time = workorder_schedule.next_occurrence_time
    utc = shift_to_utc(date, time, zone, before_seconds)
    change(cs, %{utc_date_time: utc})
  end
  def create_work_scheduler(attrs \\ %{}) do
    %WorkScheduler{}
    |> WorkScheduler.changeset(attrs)
    |> calculate_utc_datetime
    |> Repo.insert()
  end

  def update_work_scheduler(work_scheduler, attrs \\ %{}) do
    # work_scheduler = Repo.get_by!(WorkScheduler, workorder_schedule_id: workorder_schedule_id)
    work_scheduler
    |> WorkScheduler.changeset(attrs)
    |> calculate_utc_datetime
    |> Repo.update()
  end

  def delete_work_scheduler(workorder_schedule_id, prefix) do
    from(w in WorkScheduler, where: w.workorder_schedule_id == ^workorder_schedule_id and w.prefix == ^prefix)
    |> Repo.one()
    |> Repo.delete()
  end

  def delete_work_scheduler_cs(workorder_schedule_id, prefix, attrs \\ %{}) do
    query = from ws in WorkScheduler, where: (ws.workorder_schedule_id == ^workorder_schedule_id) and (ws.prefix == ^prefix)
    work_scheduler = Repo.one(query)
    # work_scheduler = Repo.get_by(WorkScheduler, workorder_schedule_id: workorder_schedule_id)
    if work_scheduler != nil do
      WorkScheduler.changeset(work_scheduler, attrs)
    else
      WorkScheduler.changeset(%WorkScheduler{}, attrs)
    end
  end

  def insert_work_scheduler_cs(attrs \\ %{}) do
    %WorkScheduler{}
      |> WorkScheduler.changeset(attrs)
      |> calculate_utc_datetime
  end

  def change_work_scheduler(%WorkScheduler{} = work_scheduler, attrs \\ %{}) do
    WorkScheduler.changeset(work_scheduler, attrs)
  end


  alias Inconn2Service.Common.IotMetering

  def list_iot_meterings do
    Repo.all(IotMetering)
  end

  def get_iot_metering!(id), do: Repo.get!(IotMetering, id)

  def create_iot_metering(attrs \\ %{}) do
    %IotMetering{}
    |> IotMetering.changeset(attrs)
    |> Repo.insert()
  end

  def update_iot_metering(%IotMetering{} = iot_metering, attrs) do
    iot_metering
    |> IotMetering.changeset(attrs)
    |> Repo.update()
  end

  def delete_iot_metering(%IotMetering{} = iot_metering) do
    Repo.delete(iot_metering)
  end


  def change_iot_metering(%IotMetering{} = iot_metering, attrs \\ %{}) do
    IotMetering.changeset(iot_metering, attrs)
  end

  alias Inconn2Service.Common.ListOfValue

  def list_list_of_values(prefix) do
    Repo.all(ListOfValue, prefix: prefix)
  end

  def get_list_of_value!(id, prefix), do: Repo.get!(ListOfValue, id, prefix: prefix)

  def create_list_of_value(attrs \\ %{}, prefix) do
    %ListOfValue{}
    |> ListOfValue.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_list_of_value(%ListOfValue{} = list_of_value, attrs, prefix) do
    list_of_value
    |> ListOfValue.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_list_of_value(%ListOfValue{} = list_of_value, prefix) do
    Repo.delete(list_of_value, prefix: prefix)
  end

  def change_list_of_value(%ListOfValue{} = list_of_value, attrs \\ %{}) do
    ListOfValue.changeset(list_of_value, attrs)
  end

  alias Inconn2Service.Common.AlertNotificationReserve

  @doc """
  Returns the list of alert_notification_reserves.

  ## Examples

      iex> list_alert_notification_reserves()
      [%AlertNotificationReserve{}, ...]

  """
  def list_alert_notification_reserves(module) do
    AlertNotificationReserve
    |> where(module: ^module)
    |> Repo.all()
  end

  # def list_alert_notification_reserves do
  #   Repo.all(AlertNotificationReserve)
  # end

  def get_alert_notification_reserve!(0), do: nil
  def get_alert_notification_reserve!(id), do: Repo.get!(AlertNotificationReserve, id)

  def get_alert_by_code(code), do: Repo.get_by(AlertNotificationReserve, [code: code])

  def get_alert_by_code_and_site_id(code, site_id), do: Repo.get_by(AlertNotificationReserve, [code: code, site_id: site_id])

  def create_alert_notification_reserve(attrs \\ %{}) do
    %AlertNotificationReserve{}
    |> AlertNotificationReserve.changeset(attrs)
    |> Repo.insert()
  end

  def update_alert_notification_reserve(%AlertNotificationReserve{} = alert_notification_reserve, attrs) do
    alert_notification_reserve
    |> AlertNotificationReserve.changeset(attrs)
    |> Repo.update()
  end

  def delete_alert_notification_reserve(%AlertNotificationReserve{} = alert_notification_reserve) do
    Repo.delete(alert_notification_reserve)
  end

  def change_alert_notification_reserve(%AlertNotificationReserve{} = alert_notification_reserve, attrs \\ %{}) do
    AlertNotificationReserve.changeset(alert_notification_reserve, attrs)
  end

  alias Inconn2Service.Common.AlertNotificationGenerator

  def list_alert_notification_generators do
    Repo.all(AlertNotificationGenerator)
  end

  def get_alert_notification_generator!(id), do: Repo.get!(AlertNotificationGenerator, id)

  def get_generator_by_reference_id_and_code(reference_id, code) do
    from(an in AlertNotificationGenerator, where: an.reference_id == ^reference_id and an.code == ^code)
    |> Repo.one()
  end

  def create_alert_notification_generator(attrs \\ %{}) do
    %AlertNotificationGenerator{}
    |> AlertNotificationGenerator.changeset(attrs)
    |> Repo.insert()
  end

  def update_alert_notification_generator(%AlertNotificationGenerator{} = alert_notification_generator, attrs) do
    alert_notification_generator
    |> AlertNotificationGenerator.changeset(attrs)
    |> Repo.update()
  end

  def delete_alert_notification_generator(%AlertNotificationGenerator{} = alert_notification_generator) do
    Repo.delete(alert_notification_generator)
  end

  def change_alert_notification_generator(%AlertNotificationGenerator{} = alert_notification_generator, attrs \\ %{}) do
    AlertNotificationGenerator.changeset(alert_notification_generator, attrs)
  end

  alias Inconn2Service.Common.AlertNotificationScheduler

  def list_alert_notification_schedulers do
    Repo.all(AlertNotificationScheduler)
  end

  def get_alert_notification_scheduler!(id), do: Repo.get!(AlertNotificationScheduler, id)

  def create_alert_notification_scheduler(attrs \\ %{}) do
    %AlertNotificationScheduler{}
    |> AlertNotificationScheduler.changeset(attrs)
    |> Repo.insert()
  end

  def update_alert_notification_scheduler(%AlertNotificationScheduler{} = alert_notification_scheduler, attrs) do
    alert_notification_scheduler
    |> AlertNotificationScheduler.changeset(attrs)
    |> Repo.update()
  end

  def delete_alert_notification_scheduler(%AlertNotificationScheduler{} = alert_notification_scheduler) do
    Repo.delete(alert_notification_scheduler)
  end

  def change_alert_notification_scheduler(%AlertNotificationScheduler{} = alert_notification_scheduler, attrs \\ %{}) do
    AlertNotificationScheduler.changeset(alert_notification_scheduler, attrs)
  end

  def generate_alert_escalations() do
    dt = DateTime.add(DateTime.utc_now, 60, :second)
    from(ans in AlertNotificationScheduler, where: ans.escalation_at_date_time <= ^dt)
    |> Repo.all()
    |> IO.inspect(label: "Alert Escalations")
    |> Enum.map(&Task.async(fn -> check_and_create_alert_escalations(&1) end))
    |> Enum.map(&Task.await/1)
  end

  defp check_and_create_alert_escalations(escalation_scheduler) do
    alerts =
      from(uan in UserAlertNotification,
        where: uan.site_id == ^escalation_scheduler.site_id and
               uan.alert_identifier_date_time == ^escalation_scheduler.alert_identifier_date_time and
               uan.type == "al" and
               uan.escalation == false and
               is_nil(uan.acknowledged_date_time),
        select: uan
      )
      |> Repo.all(prefix: escalation_scheduler.prefix)

    case alerts do
      [] ->
        delete_escalation_scheduler(escalation_scheduler)

      [alert | _] ->
        Prompt.generate_alert_escalation(alert, escalation_scheduler, escalation_scheduler.prefix)
        delete_escalation_scheduler(escalation_scheduler)
    end
  end


  # defp conditions_for_escalating_alerts(escalation_scheduler) do
  #   [
  #     site_id: escalation_scheduler.site_id,
  #     alert_identifier_date_time: escalation_scheduler.alert_identifier_date_time,
  #     type: "al",
  #     escalation: false,
  #     acknowledged_date_time: nil
  #   ]
  # end

  defp delete_escalation_scheduler(escalation_scheduler) do
    delete_alert_notification_scheduler(escalation_scheduler)
  end

  alias Inconn2Service.Common.Widget

  def list_widgets do
    Repo.all(Widget)
  end

  def get_widget!(id), do: Repo.get!(Widget, id)
  def get_widget_by_code(code), do: Repo.get_by(Widget, [code: code])

  def create_widgets(attrs \\ []) do
    Enum.map(attrs, fn x -> create_widget(x) end)
  end

  def create_widget(attrs \\ %{}) do
    %Widget{}
    |> Widget.changeset(attrs)
    |> Repo.insert()
  end

  def update_widget(%Widget{} = widget, attrs) do
    widget
    |> Widget.changeset(attrs)
    |> Repo.update()
  end

  def delete_widget(%Widget{} = widget) do
    Repo.delete(widget)
  end

  def change_widget(%Widget{} = widget, attrs \\ %{}) do
    Widget.changeset(widget, attrs)
  end

  alias Inconn2Service.Common.Feature

  def list_features do
    Repo.all(Feature)
  end

  def get_feature!(id), do: Repo.get!(Feature, id)

  def create_feature(attrs \\ %{}) do
    %Feature{}
    |> Feature.changeset(attrs)
    |> Repo.insert()
  end

  def update_feature(%Feature{} = feature, attrs) do
    feature
    |> Feature.changeset(attrs)
    |> Repo.update()
  end

  def delete_feature(%Feature{} = feature) do
    Repo.delete(feature)
  end

  def change_feature(%Feature{} = feature, attrs \\ %{}) do
    Feature.changeset(feature, attrs)
  end

  alias Inconn2Service.Common.AdminUser

  def list_admin_user do
    Repo.all(AdminUser)
  end

  def get_admin_user!(id), do: Repo.get!(AdminUser, id)

  def get_admin_user_by_username(username), do: Repo.get_by(AdminUser, username: username)

  def create_admin_user(attrs \\ %{}) do
    %AdminUser{}
    |> AdminUser.changeset(attrs)
    |> Repo.insert()
  end

  def update_admin_user(%AdminUser{} = admin_user, attrs) do
    admin_user
    |> AdminUser.changeset(attrs)
    |> Repo.update()
  end

  def delete_admin_user(%AdminUser{} = admin_user) do
    Repo.delete(admin_user)
  end

  def change_admin_user(%AdminUser{} = admin_user, attrs \\ %{}) do
    AdminUser.changeset(admin_user, attrs)
  end

  def list_public_uoms do
    Repo.all(PublicUom)
  end

  def get_public_uom!(id), do: Repo.get!(PublicUom, id)

  def create_public_uom(attrs \\ %{}) do
    %PublicUom{}
    |> PublicUom.changeset(attrs)
    |> Repo.insert()
  end

  def update_public_uom(%PublicUom{} = public_uom, attrs) do
    public_uom
    |> PublicUom.changeset(attrs)
    |> Repo.update()
  end

  def delete_public_uom(%PublicUom{} = public_uom) do
    Repo.delete(public_uom)
  end

  def change_public_uom(%PublicUom{} = public_uom, attrs \\ %{}) do
    PublicUom.changeset(public_uom, attrs)
  end

  alias Inconn2Service.Common.WorkRequestCloseScheduler

  def list_work_request_close_schedulers do
    Repo.all(WorkRequestCloseScheduler)
  end

  def get_work_request_close_scheduler!(id), do: Repo.get!(WorkRequestCloseScheduler, id)

  def create_work_request_close_scheduler(attrs \\ %{}) do
    %WorkRequestCloseScheduler{}
    |> WorkRequestCloseScheduler.changeset(attrs)
    |> Repo.insert()
  end

  def get_work_request_close_scheduler(work_request_id, prefix) do
    from(wcs in WorkRequestCloseScheduler, where: wcs.work_request_id == ^work_request_id and wcs.prefix == ^prefix)
    |> Repo.one()
  end

  def update_work_request_close_scheduler(%WorkRequestCloseScheduler{} = work_request_close_scheduler, attrs) do
    work_request_close_scheduler
    |> WorkRequestCloseScheduler.changeset(attrs)
    |> Repo.update()
  end

  def delete_work_request_close_scheduler(%WorkRequestCloseScheduler{} = work_request_close_scheduler) do
    Repo.delete(work_request_close_scheduler)
  end

  def change_work_request_close_scheduler(%WorkRequestCloseScheduler{} = work_request_close_scheduler, attrs \\ %{}) do
    WorkRequestCloseScheduler.changeset(work_request_close_scheduler, attrs)
  end
end
