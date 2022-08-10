defmodule Inconn2Service.Prompt do
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.{AssetConfig, Common}
  alias Inconn2Service.Prompt.{AlertNotificationConfig, UserAlertNotification}
  alias Inconn2Service.Workorder

  def list_alert_notification_configs(prefix) do
    Repo.all(AlertNotificationConfig, prefix: prefix)
    |> Stream.map(fn c -> preload_alert_notification_reserve(c) end)
    |> Enum.map(fn c -> preload_site(c, prefix) end)
  end

  def get_alert_notification_config!(id, prefix), do: Repo.get!(AlertNotificationConfig, id, prefix: prefix) |> preload_alert_notification_reserve() |> preload_site(prefix)

  def get_alert_notification_config_by_alert_id(alert_id, prefix) do
    # Repo.get_by(AlertNotificationConfig, [alert_notification_reserve_id: alert_id], prefix: prefix)
    from(anc in AlertNotificationConfig, where: anc.alert_notification_reserve_id == ^alert_id) |> Repo.all(prefix: prefix) |> preload_alert_notification_reserve() |> preload_site(prefix)
  end

  def get_alert_notification_config_by_alert_id_and_site_id(alert_id, site_id, prefix) do
    Repo.get_by(AlertNotificationConfig, [alert_notification_reserve_id: alert_id, site_id: site_id], prefix: prefix) |> preload_alert_notification_reserve() |> preload_site(prefix)
  end

  def create_alert_notification_config(attrs \\ %{}, prefix) do
    %AlertNotificationConfig{}
    |> AlertNotificationConfig.changeset(attrs)
    |> Repo.insert(prefix: prefix)
    |> preload_alert_notification_reserve()
    |> preload_site(prefix)
  end

  def update_alert_notification_config(%AlertNotificationConfig{} = alert_notification_config, attrs, prefix) do
    alert_notification_config
    |> AlertNotificationConfig.changeset(attrs)
    |> Repo.update(prefix: prefix)
    |> preload_alert_notification_reserve()
    |> preload_site(prefix)
  end

  def delete_alert_notification_config(%AlertNotificationConfig{} = alert_notification_config, prefix) do
    Repo.delete(alert_notification_config, prefix: prefix)
  end

  def change_alert_notification_config(%AlertNotificationConfig{} = alert_notification_config, attrs \\ %{}) do
    AlertNotificationConfig.changeset(alert_notification_config, attrs)
  end

  def list_user_alert_notifications(prefix) do
    Repo.all(UserAlertNotification, prefix: prefix)
    |> Enum.map(fn user_alert_notification -> preload_alert_notification_reserve_for_user_alert(user_alert_notification) end)
  end

  def get_user_alert_notifications_for_logged_in_user(type, user, prefix) do
    from(uan in UserAlertNotification, where: uan.type == ^type and uan.user_id == ^user.id and uan.action_taken == false)
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn user_alert_notification -> preload_alert_notification_reserve_for_user_alert(user_alert_notification) end)
  end

  def get_user_alert_notification!(id, prefix), do: Repo.get!(UserAlertNotification, id, prefix: prefix) |> preload_alert_notification_reserve_for_user_alert()

  def create_user_alert_notification(attrs \\ %{}, prefix) do
    result = %UserAlertNotification{}
              |> UserAlertNotification.changeset(attrs)
              |> Repo.insert(prefix: prefix)
    case result do
      {:ok, user_alert_notification} ->
          {:ok, user_alert_notification |> preload_alert_notification_reserve_for_user_alert()}
      _ ->
        result
    end
  end

  def discard_alerts_notifications(attrs, prefix) do
    case attrs["ids"] do
      nil ->
        []
      ids ->
        Enum.map(ids, fn id ->
          get_user_alert_notification!(id, prefix)
          |> update_user_alert_notification(%{"action_taken" => true}, prefix)
        end)
    end
  end

  def update_user_alert_notification(%UserAlertNotification{} = user_alert_notification, attrs, prefix) do
    result = user_alert_notification
              |> UserAlertNotification.changeset(attrs)
              |> Repo.update(prefix: prefix)
    case result do
      {:ok, user_alert_notification} ->
          {:ok, user_alert_notification |> preload_alert_notification_reserve_for_user_alert()}
      _ ->
        result
    end
  end

  def delete_user_alert_notification(%UserAlertNotification{} = user_alert_notification, prefix) do
    Repo.delete(user_alert_notification, prefix: prefix)
  end

  def change_user_alert_notification(%UserAlertNotification{} = user_alert_notification, attrs \\ %{}) do
    UserAlertNotification.changeset(user_alert_notification, attrs)
  end

  def generate_alert_notification(alert_notification) do
    create_alert_notification(alert_notification.reference_id, alert_notification.code, alert_notification.prefix)
    Common.delete_alert_notification_generator(alert_notification)
  end

  defp create_alert_notification(work_order_id, "WOOD", prefix) do
    work_order = Workorder.get_work_order!(work_order_id, prefix)
    {asset, _workorder_schedule} = Workorder.get_asset_from_work_order(work_order, prefix)
    description = ~s(Workorder for #{asset.name} is overdue by 10 mins)

    alert = Common.get_alert_by_code("WOOD")
    alert_config = get_alert_notification_config_by_alert_id_and_site_id(alert.id, asset.site_id, prefix)

    config_user_ids =
      case alert_config do
        nil -> []
        _ -> alert_config.addressed_to_user_ids
      end

    alert_identifier_date_time = NaiveDateTime.utc_now()
    attrs = %{
      "alert_notification_id" => alert.id,
      "type" => alert.type,
      "description" => description,
      "site_id" => asset.site_id,
      "alert_identifier_date_time" => alert_identifier_date_time
    }
    Enum.map(config_user_ids ++ [work_order.user_id], fn id ->
      create_user_alert_notification(Map.put_new(attrs, "user_id", id), prefix)
    end)
    create_escalation_entry(alert, alert_config, alert_identifier_date_time, prefix)
  end

  defp create_escalation_entry(_alert, nil, _alert_identifier_date_time, _prefix), do: nil

  defp create_escalation_entry(alert, alert_config, alert_identifier_date_time, prefix) do
    if alert.type == "al" and alert_config.is_escalation_required do
      Common.create_alert_notification_scheduler(%{
        "alert_code" => alert.code,
        "site_id" => alert_config.site_id,
        "alert_identifier_date_time" => alert_identifier_date_time,
        "escalation_at_date_time" => NaiveDateTime.add(alert_identifier_date_time, alert_config.escalation_time_in_minutes * 60),
        "escalated_to_user_ids" => alert_config.escalated_to_user_ids,
        "prefix" => prefix
      })
    end
  end

  defp preload_alert_notification_reserve_for_user_alert({:error, changeset}), do: {:error, changeset}
  defp preload_alert_notification_reserve_for_user_alert({:ok, config}), do: {:ok, preload_alert_notification_reserve(config)}
  defp preload_alert_notification_reserve_for_user_alert(config), do: Map.put(config, :alert_notification_reserve, Common.get_alert_notification_reserve!(config.alert_notification_id))

  defp preload_alert_notification_reserve({:error, changeset}), do: {:error, changeset}
  defp preload_alert_notification_reserve({:ok, config}), do: {:ok, preload_alert_notification_reserve(config)}
  defp preload_alert_notification_reserve(config), do: Map.put(config, :alert_notification_reserve, Common.get_alert_notification_reserve!(config.alert_notification_reserve_id))

  defp preload_site({:error, changeset}, _prefix), do: {:error, changeset}
  defp preload_site({:ok, config}, prefix), do: {:ok, preload_site(config, prefix)}
  defp preload_site(config, prefix), do: Map.put(config, :site, AssetConfig.get_site(config.site_id, prefix))
end
