defmodule Inconn2Service.DataHandling.DeleteData do
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Account
  alias Inconn2Service.Prompt.AlertNotificationConfig
  alias Inconn2Service.Prompt.UserAlertNotification
  alias Inconn2Service.Communication
  alias Inconn2Service.Common.{AlertNotificationReserve, AlertNotificationScheduler, AlertNotificationGenerator, PublicUom}

  # Delete data in alert notification reserve table
  def delete_data_in_alert_notification_reserve() do
    AlertNotificationReserve
    |> Repo.delete_all()
  end

  #delete data in alert notification scheduler table
  def delete_data_in_alert_notification_scheduler() do
    AlertNotificationScheduler
    |> Repo.delete_all()
  end

  #delete data in alert notification generator table
  def delete_data_in_alert_notification_generator() do
    AlertNotificationGenerator
    |> Repo.delete_all()
  end

  #delete data in public uom table
  def delete_data_in_public_uom() do
    PublicUom
    |> Repo.delete_all()
  end

  #list prefixes
  def list_prefixes() do
    Account.list_licensees()
    |> Enum.map(fn licensee -> "inc_" <> licensee.sub_domain end)
  end

  #delete data in alert notification config table
  def delete_data_in_alert_notification_config() do
    list_prefixes()
    |> Enum.each(fn prefix ->
      AlertNotificationConfig
      |> Repo.delete_all(prefix: prefix)
      end)
  end

  #delete data in user alert notification table
  def delete_data_in_user_alert_notification() do
    list_prefixes()
    |> Enum.each(fn prefix ->
      UserAlertNotification
      |> Repo.delete_all(prefix: prefix)
   end)
  end

  #delete message template for the particular code
  def delete_data_in_message_template_based_on_the_code(code) do
    message_template =
          Communication.get_message_template_by_code(code)

    if message_template do
      Repo.delete!(message_template)
      {:ok, "Message template deleted successfully."}
    else
      {:error, "Message template not found."}
    end
  end

end
