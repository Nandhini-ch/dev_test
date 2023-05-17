alias Inconn2Service.Common
alias Inconn2Service.Prompt

alerts = Common.list_alert_notification_reserves()

result =
Enum.map(alerts, fn alert ->
  Prompt.create_alert_notification_config(
    %{
      "addressed_to_user_ids" => [1,2],
      "alert_notification_reserve_id" => alert.id,
      "is_escalation_required" => true,
      # "escalated_to_user_ids" => [4, 5],
      "escalation_time_in_minutes" => 1,
      "site_id" => 1
    },
    "inc_bata"
  )
end)

IO.inspect(result)
