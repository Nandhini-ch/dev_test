alias Inconn2Service.Common
# alias Inconn2Service.Common.Alert

#alerts for asset module
alert = %{"module" => "Asset","description" => "Asset Status Change to breakdown","type" => "al","code" => "ASSB"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Asset","description" => "Asset Status change to on/ off","type" => "nt","code" => "ASST"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Asset","description" => "Asset parameter out of validation","type" => "al","code" => "ASPV"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Asset","description" => "Add new asset","type" => "nt","code" => "ASNW"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Asset","description" => "Modify asset tree heirachy","type" => "nt","code" => "ASMH"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Asset","description" => "Edit asset details","type" => "nt","code" => "ASED"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Asset","description" => "Remove asset","type" => "al","code" => "ASRA"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO assigned","type" => "nt","code" => "WOAS"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO start due 10 mins","type" => "nt","code" => "WOTM"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO start over due by 10 mins","type" => "al","code" => "WOOD"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO not completed by scheduled time","type" => "al","code" => "WONC"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "Work permit approval required","type" => "nt","code" => "WPAR"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "Work permit approved","type" => "nt","code" => "WPAP"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "LOTO approval required","type" => "nt","code" => "LTAR"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "LOTO Checked and approved","type" => "nt","code" => "LTAP"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO approval required","type" => "nt","code" => "WOAR"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO approved","type" => "nt","code" => "WOAP"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO completion acknowledment required","type" => "nt","code" => "WACR"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO completion acknowledged","type" => "nt","code" => "WACK"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO status change to Hold","type" => "al","code" => "WOHL"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO re-assigned/ re-scheduled","type" => "al","code" => "WORE"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "Work order cancelled","type" => "al","code" => "WOCL"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO template modified","type" => "nt","code" => "WOTE"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO schedule modified","type" => "nt","code" => "WOSE"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "New work order template added","type" => "nt","code" => "WTNW"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Maintenance","description" => "WO template deleted","type" => "nt","code" => "WTDT"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "New ticket generated","type" => "nt","code" => "WRNW"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "New ticket assigned","type" => "nt","code" => "WRAS"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "Ticket approval status change", "type" => "nt","code" => "WRAR"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "Ticket completed","type" => "nt","code" => "WRCP"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "Ticket TAT expired","type" => "al","code" => "WREP"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "Ticket cancelled","type" => "al","code" => "WRCL"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "Ticket re-assigned/re-scheduled","type" => "al","code" => "WRRE"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "Ticket new category/ sub category added","type" => "nt","code" => "WRCN"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Ticketing","description" => "Ticket re-opened","type" => "al","code" => "WRRO"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Inventory","description" => "stock below re-order value","type" => "al","code" => "INSB"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Inventory","description" => "Critical stock below re-order level","type" => "al","code" => "INCB"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Inventory","description" => "Issue approval raised","type" => "nt","code" => "INIA"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Inventory","description" => "Issue approvaed","type" => "nt","code" => "INIP"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Inventory","description" => "Issue receipt acknowledgement","type" => "nt","code" => "INRA"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "Inventory","description" => "Issue receipt not acknowledged","type" => "al","code" => "ISNA"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "People","description" => "New user added","type" => "nt","code" => "PENW"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "People","description" => "New roster added","type" => "nt","code" => "PENR"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "People","description" => "New shift added","type" => "nt","code" => "PENS"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "People","description" => "New reportee added","type" => "nt","code" => "PENR"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "People","description" => "New organisation added","type" => "nt","code" => "PRNO"}
Common.create_alert_notification_reserve(alert)

alert = %{"module" => "People","description" => "Employee absent in shift","type" => "al","code" => "PEEA"}
Common.create_alert_notification_reserve(alert)
