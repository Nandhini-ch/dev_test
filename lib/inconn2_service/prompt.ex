defmodule Inconn2Service.Prompt do
  @moduledoc """
  The Prompt context.
  """

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Prompt.AlertNotificationConfig

  @doc """
  Returns the list of alert_notification_configs.

  ## Examples

      iex> list_alert_notification_configs()
      [%AlertNotificationConfig{}, ...]

  """
  def list_alert_notification_configs(prefix) do
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
  def get_alert_notification_config!(id, prefix), do: Repo.get!(AlertNotificationConfig, id, prefix: prefix)

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

  alias Inconn2Service.Prompt.UserAlert

  @doc """
  Returns the list of user_alerts.

  ## Examples

      iex> list_user_alerts()
      [%UserAlert{}, ...]

  """
  def list_user_alerts do
    Repo.all(UserAlert)
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
  def get_user_alert!(id), do: Repo.get!(UserAlert, id)

  @doc """
  Creates a user_alert.

  ## Examples

      iex> create_user_alert(%{field: value})
      {:ok, %UserAlert{}}

      iex> create_user_alert(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_alert(attrs \\ %{}) do
    %UserAlert{}
    |> UserAlert.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_alert.

  ## Examples

      iex> update_user_alert(user_alert, %{field: new_value})
      {:ok, %UserAlert{}}

      iex> update_user_alert(user_alert, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_alert(%UserAlert{} = user_alert, attrs) do
    user_alert
    |> UserAlert.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_alert.

  ## Examples

      iex> delete_user_alert(user_alert)
      {:ok, %UserAlert{}}

      iex> delete_user_alert(user_alert)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_alert(%UserAlert{} = user_alert) do
    Repo.delete(user_alert)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_alert changes.

  ## Examples

      iex> change_user_alert(user_alert)
      %Ecto.Changeset{data: %UserAlert{}}

  """
  def change_user_alert(%UserAlert{} = user_alert, attrs \\ %{}) do
    UserAlert.changeset(user_alert, attrs)
  end
end
