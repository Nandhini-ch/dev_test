defmodule Inconn2Service.Prompt do
  @moduledoc """
  The Prompt context.
  """
  # import Inconn2Service.Util.DeleteManager
  import Ecto.Query, warn: false
  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Repo

  alias Inconn2Service.{AssetConfig, Common}
  alias Inconn2Service.Prompt.{AlertNotificationConfig, UserAlertNotification}
  alias Inconn2Service.Workorder
  alias Inconn2Service.Communication
  alias Inconn2Service.Email
  alias Inconn2Service.Staff

  def list_alert_notification_configs(site_id, prefix) do
    AlertNotificationConfig
    |> Repo.add_active_filter()
    |> where(site_id: ^site_id)
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn c -> preload_alert_notification_reserve(c) end)
    |> Enum.map(fn c -> preload_site(c, prefix) end)
  end

  def get_alert_notification_config!(id, prefix), do: Repo.get!(AlertNotificationConfig, id, prefix: prefix) |> preload_alert_notification_reserve() |> preload_site(prefix)

  def get_alert_notification_config_by_alert_id(alert_id, prefix) do
    from(anc in AlertNotificationConfig, where: anc.alert_notification_reserve_id == ^alert_id)
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
  end

  def get_alert_notification_config_by_alert_id_and_site_id(alert_id, site_id, prefix) do
    from(anc in AlertNotificationConfig, where: anc.alert_notification_reserve_id == ^alert_id and anc.site_id == ^site_id)
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> preload_alert_notification_reserve()
    |> preload_site(prefix)
  end

  def get_alert_notification_config_by_reserve_and_site(alert_notification_reserve_id, site_id, prefix) do
    from(anc in AlertNotificationConfig, where: anc.alert_notification_reserve_id == ^alert_notification_reserve_id and anc.site_id == ^site_id)
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
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

  # def delete_alert_notification_config(%AlertNotificationConfig{} = alert_notification_config, prefix) do
  #   Repo.delete(alert_notification_config, prefix: prefix)
  # end

  #soft delete for alert notification config
  def delete_alert_notification_config(%AlertNotificationConfig{} = alert_notification_config, prefix) do
    update_alert_notification_config(alert_notification_config, %{"active" => false}, prefix)
         {:deleted,
            "The Alert Notification Config Was Disabled"
         }
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
        # "escalated_to_user_ids" => alert_config.escalated_to_user_ids,
        "prefix" => prefix
      })
    end
  end

  defp preload_alert_notification_reserve_for_user_alert(nil), do: nil
  defp preload_alert_notification_reserve_for_user_alert({:error, changeset}), do: {:error, changeset}
  defp preload_alert_notification_reserve_for_user_alert({:ok, config}), do: {:ok, preload_alert_notification_reserve(config)}
  defp preload_alert_notification_reserve_for_user_alert(config), do: Map.put(config, :alert_notification_reserve, Common.get_alert_notification_reserve!(config.alert_notification_id))

  defp preload_alert_notification_reserve(nil), do: nil
  defp preload_alert_notification_reserve({:error, changeset}), do: {:error, changeset}
  defp preload_alert_notification_reserve({:ok, config}), do: {:ok, preload_alert_notification_reserve(config)}
  defp preload_alert_notification_reserve(config), do: Map.put(config, :alert_notification_reserve, Common.get_alert_notification_reserve!(config.alert_notification_reserve_id))

  defp preload_site(nil, _prefix), do: nil
  defp preload_site({:error, changeset}, _prefix), do: {:error, changeset}
  defp preload_site({:ok, config}, prefix), do: {:ok, preload_site(config, prefix)}
  defp preload_site(config, prefix), do: Map.put(config, :site, AssetConfig.get_site(config.site_id, prefix))

  def generate_alert_notification(code, site_id, an_arguments_list, sms_arguements_list, specific_user_maps, escalation_user_maps, prefix) do
    an_reserve = Common.get_alert_by_code(code)
    an_config = get_alert_notification_config_by_reserve_and_site(an_reserve.id, site_id, prefix)

    message = form_message_text_from_template(an_reserve.text_template, an_arguments_list)

    user_maps =
      specific_user_maps ++
      Enum.map(an_config.addressed_to_users, fn user_map -> Staff.add_display_name_to_user_map(user_map, prefix) end)

    escalation_user_maps =
      escalation_user_maps ++
      Enum.map(an_config.escalated_to_users, fn user_map -> Staff.add_display_name_to_user_map(user_map, prefix) end)

    Enum.map(user_maps, fn user_map ->
      trigger_alert_notification(message, an_reserve, site_id, user_map["user_id"], an_config, escalation_user_maps, prefix)
    end)

    if an_config.is_sms_required do
      user_maps
      |> Enum.reject(fn user_map -> is_nil(user_map["mobile_no"]) end)
      |> Enum.map(fn user_map ->
        Communication.form_and_send_sms(an_reserve.sms_code, "91" <> user_map["mobile_no"], [user_map["display_name"] | sms_arguements_list], prefix)
      end)
    end

    if an_config.is_email_required do
      user_maps
      |> Enum.reject(fn user_map -> is_nil(user_map["email"]) end)
      |> Enum.map(fn user_map ->
        Email.send_alert_notification_email(user_map["email"], user_map["display_name"], an_reserve.type, message)
      end)
    end

  end

  defp trigger_alert_notification(message, an_reserve, site_id, user_id, an_config, escalation_user_maps, prefix) do
    alert_identifier_date_time = NaiveDateTime.utc_now()
    %{
      "alert_notification_id" => an_reserve.id,
      "alert_identifier_date_time" => alert_identifier_date_time,
      "type" => an_reserve.type,
      "site_id" => site_id,
      "user_id" => user_id,
      "description" => message
    }
    |> create_user_alert_notification(prefix)

    if an_reserve.type == "al" and an_config.is_escalation_required and length(escalation_user_maps) != 0 do
      %{
        "alert_code" => an_reserve.code,
        "alert_identifier_date_time" => alert_identifier_date_time,
        "escalation_at_date_time" => NaiveDateTime.add(alert_identifier_date_time, an_config.escalation_time_in_minutes * 60),
        "escalated_to_users" => escalation_user_maps,
        "site_id" => site_id,
        "prefix" => prefix
      }
      |> Common.create_alert_notification_scheduler()
    end
  end

  def generate_alert_escalation(alert, escalation_scheduler, prefix) do
    an_reserve = Common.get_alert_by_code(escalation_scheduler.alert_code)
    an_config = get_alert_notification_config_by_reserve_and_site(alert.alert_notification_id, alert.site_id, prefix)
    user_maps = escalation_scheduler.escalated_to_users

    Enum.map(user_maps, fn user_map ->
      trigger_alert_escalation(alert.description, alert, alert.site_id, user_map["user_id"], prefix)
    end)

    if an_config.is_sms_required do
      user_maps
      |> Enum.reject(fn user_map -> is_nil(user_map["mobile_no"]) end)
      |> Enum.map(fn user_map ->
        Communication.form_and_send_sms(an_reserve.sms_code, "91" <> user_map["mobile_no"], [user_map["display_name"] | []], prefix)
      end)
    end

    if an_config.is_email_required do
      user_maps
      |> Enum.reject(fn user_map -> is_nil(user_map["email"]) end)
      |> Enum.map(fn user_map ->
        Email.send_alert_notification_email(user_map["email"], user_map["display_name"], an_reserve.type, alert.description)
      end)
    end
  end

  defp trigger_alert_escalation(message, alert, site_id, user_id, prefix) do
    alert_identifier_date_time = NaiveDateTime.utc_now()
    %{
      "alert_notification_id" => alert.alert_notification_id,
      "alert_identifier_date_time" => alert_identifier_date_time,
      "type" => alert.type,
      "site_id" => site_id,
      "user_id" => user_id,
      "description" => message,
      "escalation" => true
    }
    |> create_user_alert_notification(prefix)
  end

end
