alias Inconn2Service.Common
# alias Inconn2Service.Common.Alert

#alerts for asset module
alert = %{"module" => "Asset","description" => "Asset Status Change to breakdown","type" => "Alert","code" => "ASSB"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Asset","description" => "Asset Status change to on/ off","type" => "Notification","code" => "ASST"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Asset","description" => "Asset parameter out of validation","type" => "Alert","code" => "ASPV"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Asset","description" => "Add new asset","type" => "Notification","code" => "ASNW"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Asset","description" => "Modify asset tree heirachy","type" => "Notification","code" => "ASMH"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Asset","description" => "Edit asset details","type" => "Notification","code" => "ASED"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Asset","description" => "Remove asset","type" => "Alert","code" => "ASRA"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO assigned","type" => "Notification","code" => "WOAS"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO start due 10 mins","type" => "Notification","code" => "WOTM"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO start over due by 10 mins","type" => "Alert","code" => "WOOD"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO not completed by scheduled time","type" => "Alert","code" => "WONC"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "Work permit approval required","type" => "Notification","code" => "WPAR"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "Work permit approved","type" => "Notification","code" => "WPAP"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "LOTO approval required","type" => "Notification","code" => "LTAR"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "LOTO Checked and approved","type" => "Notification","code" => "LTAP"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO approval required","type" => "Notification","code" => "WOAR"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO approved","type" => "Notification","code" => "WOAP"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO completion acknowledment required","type" => "Notification","code" => "WACR"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO completion acknowledged","type" => "Notification","code" => "WACK"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO status change to Hold","type" => "Alert","code" => "WOHL"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO re-assigned/ re-scheduled","type" => "Alert","code" => "WORE"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "Work order cancelled","type" => "Alert","code" => "WOCL"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO template modified","type" => "Notification","code" => "WOTE"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO schedule modified","type" => "Notification","code" => "WOSE"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "New work order template added","type" => "Notification","code" => "WTNW"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO template deleted","type" => "Notification","code" => "WTDT"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "New ticket generated","type" => "Notification","code" => "WRNW"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "New ticket assigned","type" => "Notification","code" => "WRAS"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "Ticket approval status change","type" => "Notification","code" => "WRAS"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "Ticket completed","type" => "Notification","code" => "WRCP"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "Ticket TAT expired","type" => "Alert","code" => "WREP"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "Ticket cancelled","type" => "Alert","code" => "WRCL"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "Ticket re-asigned/re-scheduled","type" => "Alert","code" => "Alert"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "Ticket new category/ sub category added","type" => "Notification","code" => "WRCN"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "Ticket re-opened","type" => "Alert","code" => "WRRE"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Inventory","description" => "stock below re-order value","type" => "Alert","code" => "INSB"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Inventory","description" => "Critical stock below re-order level","type" => "Alert","code" => "INCB"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Inventory","description" => "Issue approval raised","type" => "Notification","code" => "INIA"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Inventory","description" => "Issue approvaed","type" => "Notification","code" => "INIP"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Inventory","description" => "Issue receipt acknowledgement","type" => "Notification","code" => "INRA"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Inventory","description" => "Issue receipt not acknowledged","type" => "Alert","code" => "ISNA"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "People","description" => "New user added","type" => "Notification","code" => "PENW"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "People","description" => "New roster added","type" => "Notification","code" => "PENR"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "People","description" => "New shift added","type" => "Notification","code" => "PENS"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "People","description" => "New reportee added","type" => "Notification","code" => "PENR"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "People","description" => "New organisation added","type" => "Notification","code" => "PRNO"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "People","description" => "Employee absent in shift","type" => "Alert","code" => "PEEA"}
Common.create_alert_notification_reserve(alert)
