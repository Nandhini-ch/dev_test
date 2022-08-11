defmodule Inconn2Service.Prompt do
  @moduledoc """
  The Prompt context.
  """
  # import Inconn2Service.Util.DeleteManager
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Common
  alias Inconn2Service.Prompt.AlertNotificationConfig
  alias Inconn2Service.Workorder

  @doc """
  Returns the list of alert_notification_configs.

  ## Examples

      iex> list_alert_notification_configs()
      [%AlertNotificationConfig{}, ...]

  """
  def list_alert_notification_configs(prefix) do
    AlertNotificationConfig
     |> Repo.add_active_filter()
      Repo.all(AlertNotificationConfig, prefix: prefix)
  end

  @doc """
  Gets a single alert_notification_config.

  Raises `Ecto.NoResultsError` if the Alert notification config does not exist.

  ## Examples

      iex> get_alert_notification_config!(123)
      %AlertNotificationConfig{}

      iex> get_alert_notification_config!(456)
      ** (Ecto.NoResultsError)

  """
  def get_alert_notification_config!(id, prefix), do: Repo.get!(AlertNotificationConfig, id, prefix: prefix)\

  def get_alert_notification_config_by_alert_id(alert_id, prefix) do
    # Repo.get_by(AlertNotificationConfig, [alert_notification_reserve_id: alert_id], prefix: prefix)
    from(anc in AlertNotificationConfig, where: anc.alert_notification_reserve_id == ^alert_id) |> Repo.all(prefix: prefix)
  end

  def get_alert_notification_config_by_alert_id_and_site_id(alert_id, site_id, prefix) do
    Repo.get_by(AlertNotificationConfig, [alert_notification_reserve_id: alert_id, site_id: site_id], prefix: prefix)
  end

  @doc """
  Creates a alert_notification_config.

  ## Examples

      iex> create_alert_notification_config(%{field: value})
      {:ok, %AlertNotificationConfig{}}

      iex> create_alert_notification_config(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_alert_notification_config(attrs \\ %{}, prefix) do
    %AlertNotificationConfig{}
    |> AlertNotificationConfig.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a alert_notification_config.

  ## Examples

      iex> update_alert_notification_config(alert_notification_config, %{field: new_value})
      {:ok, %AlertNotificationConfig{}}

      iex> update_alert_notification_config(alert_notification_config, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_alert_notification_config(%AlertNotificationConfig{} = alert_notification_config, attrs, prefix) do
    alert_notification_config
    |> AlertNotificationConfig.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a alert_notification_config.

  ## Examples

      iex> delete_alert_notification_config(alert_notification_config)
      {:ok, %AlertNotificationConfig{}}

      iex> delete_alert_notification_config(alert_notification_config)
      {:error, %Ecto.Changeset{}}

  """
  def delete_alert_notification_config(%AlertNotificationConfig{} = alert_notification_config, prefix) do
    Repo.delete(alert_notification_config, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking alert_notification_config changes.

  ## Examples

      iex> change_alert_notification_config(alert_notification_config)
      %Ecto.Changeset{data: %AlertNotificationConfig{}}

  """
  def change_alert_notification_config(%AlertNotificationConfig{} = alert_notification_config, attrs \\ %{}) do
    AlertNotificationConfig.changeset(alert_notification_config, attrs)
  end

  alias Inconn2Service.Prompt.UserAlertNotification

  @doc """
  Returns the list of user_alerts.

  ## Examples

      iex> list_user_alerts()
      [%UserAlert{}, ...]

  """
  def list_user_alert_notifications(prefix) do
    Repo.all(UserAlertNotification, prefix: prefix)
    |> Enum.map(fn user_alert_notification -> preload_alert_notification_reserve(user_alert_notification) end)
  end

  def get_user_alert_notifications_for_logged_in_user(type, user, prefix) do
    from(uan in UserAlertNotification, where: uan.type == ^type and uan.user_id == ^user.id and uan.action_taken == false)
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn user_alert_notification -> preload_alert_notification_reserve(user_alert_notification) end)
  end
  @doc """
  Gets a single user_alert.

  Raises `Ecto.NoResultsError` if the User alert does not exist.

  ## Examples

      iex> get_user_alert!(123)
      %UserAlert{}

      iex> get_user_alert!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_alert_notification!(id, prefix), do: Repo.get!(UserAlertNotification, id, prefix: prefix) |> preload_alert_notification_reserve()

  defp preload_alert_notification_reserve(user_alert_notification) do
    alert_notification_reserve = Common.get_alert_notification_reserve!(user_alert_notification.alert_notification_id)
    Map.put(user_alert_notification, :alert_notification, alert_notification_reserve)
  end
  @doc """
  Creates a user_alert.

  ## Examples

      iex> create_user_alert(%{field: value})
      {:ok, %UserAlert{}}

      iex> create_user_alert(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_alert_notification(attrs \\ %{}, prefix) do
    result = %UserAlertNotification{}
              |> UserAlertNotification.changeset(attrs)
              |> Repo.insert(prefix: prefix)
    case result do
      {:ok, user_alert_notification} ->
          {:ok, user_alert_notification |> preload_alert_notification_reserve()}
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

  @doc """
  Updates a user_alert.

  ## Examples

      iex> update_user_alert(user_alert, %{field: new_value})
      {:ok, %UserAlert{}}

      iex> update_user_alert(user_alert, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_alert_notification(%UserAlertNotification{} = user_alert_notification, attrs, prefix) do
    result = user_alert_notification
              |> UserAlertNotification.changeset(attrs)
              |> Repo.update(prefix: prefix)
    case result do
      {:ok, user_alert_notification} ->
          {:ok, user_alert_notification |> preload_alert_notification_reserve()}
      _ ->
        result
    end
  end

  @doc """
  Deletes a user_alert.

  ## Examples

      iex> delete_user_alert(user_alert)
      {:ok, %UserAlert{}}

      iex> delete_user_alert(user_alert)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_alert_notification(%UserAlertNotification{} = user_alert_notification, prefix) do
    Repo.delete(user_alert_notification, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_alert changes.

  ## Examples

      iex> change_user_alert(user_alert)
      %Ecto.Changeset{data: %UserAlert{}}

  """
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
        "alert_identifier_date_time" => alert_identifier_date_time,
        "escalation_at_date_time" => NaiveDateTime.add(alert_identifier_date_time, alert_config.escalation_time_in_minutes * 60),
        "prefix" => prefix
      })
    end
  end

end
