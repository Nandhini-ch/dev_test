alias Inconn2Service.Common
alias Inconn2Service.Prompt

alerts = Common.list_alert_notification_reserves()

Enum.each(alerts, fn alert ->
  Prompt.create_alert_notification_config(
    %{
      "addressed_to_user_ids" => [1,2],
      "alert_notification_reserve_id" => alert.id,
      "site_id" => 1
    },
    "inc_bata"
  )
end)
