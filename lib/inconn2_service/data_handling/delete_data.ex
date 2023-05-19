defmodule Inconn2Service.DataHandling.DeleteData do
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Account
  alias Inconn2Service.Prompt.AlertNotificationConfig
  alias Inconn2Service.Prompt.UserAlertNotification
  alias Inconn2Service.Common.{AlertNotificationReserve, AlertNotificationScheduler, AlertNotificationGenerator, PublicUom}

  def delete_data_in_alert_notification_reserve() do
    AlertNotificationReserve
    |> Repo.delete_all()
  end

  def delete_data_in_alert_notification_scheduler() do
    AlertNotificationScheduler
    |> Repo.delete_all()
  end

  def delete_data_in_alert_notification_generator() do
    AlertNotificationGenerator
    |> Repo.delete_all()
  end

  def delete_data_in_public_uom() do
    PublicUom
    |> Repo.delete_all()
  end

  def list_prefixes() do
    Account.list_licensees()
    |> Enum.map(fn licensee -> "inc_" <> licensee.sub_domain end)
  end

  def delete_data_in_alert_notification_config() do
    list_prefixes()
    |> Enum.each(fn prefix ->
      AlertNotificationConfig
      |> Repo.delete_all(prefix: prefix)
      end)
  end

  def delete_data_in_user_alert_notification() do
    list_prefixes()
    |> Enum.each(fn prefix ->
      UserAlertNotification
      |> Repo.delete_all(prefix: prefix)
   end)
  end

end
