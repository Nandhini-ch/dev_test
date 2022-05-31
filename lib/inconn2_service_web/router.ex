defmodule Inconn2ServiceWeb.Router do
  use Inconn2ServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Inconn2ServiceWeb.Plugs.MatchTenantPlug
  end

  pipeline :authenticate do
    plug(Inconn2ServiceWeb.Plugs.GuardianAuthPipeline)
    plug(Inconn2ServiceWeb.Plugs.AssignUser)
  end

  scope "/api", Inconn2ServiceWeb do
    pipe_through :api
    resources "/business_types", BusinessTypeController, except: [:new, :edit]
    resources "/licensees", LicenseeController, except: [:new, :edit]
    get "/timezones", TimezoneController, :index
    get "/equipments/:id/qr_code", EquipmentController, :display_qr_code
    get "/locations/:id/qr_code", LocationController, :display_qr_code


    post "/sessions/login", SessionController, :login

    resources "/iot_meterings", IotMeteringController, only: [:create, :show]

    get "/manage_data_discrepancy_site_config", AssetController, :manage_data_discrepancy

    get "/populate_timezone", AlertNotificationReserveController, :populate_timezones
    get "/populate_alerts", AlertNotificationReserveController, :populate_alerts

  end

  scope "/api", Inconn2ServiceWeb do
    pipe_through [:api, :authenticate]

    resources "/sites", SiteController, except: [:new, :edit]
    resources "/site_config", SiteConfigController, except: [:new, :edit]
    get "/sites?active=true", SiteController, :index
    get "/sites?active=false", SiteController, :index
    put "/sites/:id/activate", SiteController, :activate_site
    put "/sites/:id/deactivate", SiteController, :activate_site
    get "/download_sites", ReferenceDownloadController, :download_sites
    post "/upload_sites", ReferenceUploadController, :upload_sites

    resources "/asset_categories", AssetCategoryController, except: [:new, :edit]
    get "/asset_categories_tree", AssetCategoryController, :tree
    get "/asset_categories/nodes/leaves", AssetCategoryController, :leaves
    get "/asset_categories/:id/assets", AssetCategoryController, :assets
    put "/asset_categories/:id/deactivate", AssetCategoryController, :deactivate_asset_category
    put "/asset_categories/:id/activate", AssetCategoryController, :activate_asset_category
    get "/download_asset_categories", ReferenceDownloadController, :download_asset_categories
    post "/upload_asset_categories", ReferenceUploadController, :upload_asset_categories

    resources "/alert_notification_reserves", AlertNotificationReserveController, except: [:new, :edit]
    resources "/alert_notification_configs", AlertNotificationConfigController, except: [:new, :edit]
    resources "/user_alert_notifications", UserAlertNotificationController, except: [:new, :edit]
    get "/user_alert_notifications_for_logged_in_user", UserAlertNotificationController, :get_user_alert_notifications_for_logged_in_user
    post "/acknowledge_alert/:id", UserAlertNotificationController, :acknowledge_alert
    post "/discard_alerts_notifications", UserAlertNotificationController, :discard_alerts_notifications

    get "/sites/:site_id/locations/qr_codes", LocationController, :list_locations_qr
    put "/locations/group_update", LocationController, :group_update
    resources "/locations", LocationController, except: [:new, :edit, :index]
    # get "/locations/:id/qr_code", LocationController, :display_qr_code
    get "/locations/qr_code/:qr_code", LocationController, :get_location_from_qr_code
    get "/locations/:id/qr_code_as_pdf", LocationController, :display_qr_code_as_pdf
    put "/locations/:id/activate", LocationController, :activate_location
    put "/locations/:id/deactivate", LocationController, :deactivate_location
    get "/sites/:site_id/locations", LocationController, :index
    get "/sites/:site_id/locations_tree", LocationController, :tree
    get "/sites/:site_id/locations/leaves", LocationController, :leaves
    get "/download_locations", ReferenceDownloadController, :download_locations
    post "/upload_locations", ReferenceUploadController, :upload_locations

    get "/sites/:site_id/equipments/qr_codes", EquipmentController, :list_equipments_qr
    put "/equipments/group_update", EquipmentController, :group_update
    resources "/equipments", EquipmentController, except: [:new, :edit, :index]
    # get "/equipments/:id/qr_code", EquipmentController, :display_qr_code
    get "/equipments/qr_code/:qr_code", EquipmentController, :get_equipment_from_qr_code
    get "/equipments/:id/qr_code_as_pdf", EquipmentController, :display_qr_code_as_pdf
    get "/sites/:site_id/equipments", EquipmentController, :index
    get "/sites/:site_id/equipments_tree", EquipmentController, :tree
    get "/sites/:site_id/equipments/leaves", EquipmentController, :leaves
    put "/equipments/:id/activate", EquipmentController, :activate_equipment
    put "/equipments/:id/deactivate", EquipmentController, :deactivate_equipment
    get "/equipments/:equipment_id/location_path", EquipmentController, :loc_path
    get "/locations/:location_id/equipments", EquipmentController, :loc_equipments
    get "/download_equipments", ReferenceDownloadController, :download_equipments
    post "/upload_equipments", ReferenceUploadController, :upload_equipments


    get "/assets/:site_id/list/locations", AssetController, :get_locations_with_offset
    get "/assets/:site_id/list/equipments", AssetController, :get_equipments_with_offset
    get "/assets/:qr_code/", AssetController, :get_asset_from_qr_code

    resources "/asset_status_tracks", AssetStatusTrackController, except: [:new, :edit]

    resources "/shifts", ShiftController, except: [:new, :edit]
    put "/shifts/:id/activate", ShiftController, :activate_shift
    put "/shifts/:id/deactivate", ShiftController, :deactivate_shift
    get "/download_shifts", ReferenceDownloadController, :download_shifts
    post "/upload_shifts", ReferenceUploadController, :upload_shifts
    resources "/bankholidays", HolidayController, except: [:new, :edit]
    put "/bankholidays/:id/activate", HolidayController, :activate_holiday
    put "/bankholidays/:id/deactivate", HolidayController, :deactivate_holiday
    get "/download_bankholidays", ReferenceDownloadController, :download_bankholidays
    post "/upload_bankholidays", ReferenceUploadController, :upload_bankholidays
    resources "/parties", PartyController, except: [:new, :edit]

    resources "/tasks", TaskController, except: [:new, :edit]
    put "/tasks/:id/activate", TaskController, :activate_task
    put "/tasks/:id/deactivate", TaskController, :deactivate_task
    get "/download_tasks", ReferenceDownloadController, :download_tasks
    post "/upload_tasks", ReferenceUploadController, :upload_tasks
    resources "/task_lists", TaskListController, except: [:new, :edit]
    put "/task_lists/:id/activate", TaskListController, :activate_task_list
    put "/task_lists/:id/deactivate", TaskListController, :activate_task_list
    get "/download_task_lists", ReferenceDownloadController, :download_task_lists
    post "/upload_task_lists", ReferenceUploadController, :upload_task_lists

    resources "/checks", CheckController, except: [:new, :edit]
    put "/checks/:id/activate", CheckController, :activate_check
    put "/checks/:id/deactivate", CheckController, :deactivate_check
    get "/download_checks", ReferenceDownloadController, :download_checks_lists
    post "/upload_checks", ReferenceUploadController, :upload_checks
    resources "/check_lists", CheckListController, except: [:new, :edit]
    put "/check_lists/:id/activate", CheckListController, :activate_check_list
    put "/check_lists/:id/deactivate", CheckListController, :deactivate_check_list
    get "/download_check_lists", ReferenceDownloadController, :download_check_lists
    post "/upload_check_lists", ReferenceUploadController, :upload_check_lists

    resources "/workorder_templates", WorkorderTemplateController, except: [:new, :edit]
    resources "/workorder_schedules", WorkorderScheduleController, except: [:new, :edit]
    get "/work_orders_of_user", WorkOrderController, :work_orders_of_user
    get "/work_orders/enable_start/:id", WorkOrderController, :enable_start
    get "/work_orders/:id/next_step", WorkOrderController, :next_step
    put "/work_orders/:id/send_for_workflow_approvals/:type", WorkOrderController, :send_for_workflow_approvals
    # put "/work_orders/:id/send_for_workpermit_approval", WorkOrderController, :send_for_workpermit_approval
    # put "/work_orders/:id/send_for_work_order_approval", WorkOrderController, :send_for_work_order_approval
    # put "/work_orders/:id/send_for_loto_lock_approval", WorkOrderController, :send_for_loto_lock_approval
    # put "/work_orders/:id/send_for_loto_release_approval", WorkOrderController, :send_for_loto_release_approval
    get "/work_orders/permit_approvals_pending", WorkOrderController, :work_order_premits_to_be_approved
    get "/work_orders/workorder_approvals_pending", WorkOrderController, :work_orders_to_be_approved
    get "/work_orders/workorder_acknowledgement_pending", WorkOrderController, :work_orders_to_be_acknowledged
    post "/work_orders/approve_permit/:id", WorkOrderController, :approve_work_permit
    post "/work_orders/approve_loto_lock/:id", WorkOrderController, :approve_loto_lock
    post "/work_orders/approve_loto_release/:id", WorkOrderController, :approve_loto_release
    get "/work_orders/loto_lock_pending", WorkOrderController, :work_order_loto_lock_to_be_checked
    get "/work_orders/loto_release_pending", WorkOrderController, :work_order_loto_release_to_be_checked
    put "/pause_work_order/:id", WorkOrderController, :pause_work_order
    put "/resume_work_order/:id", WorkOrderController, :resume_work_order
    post "/work_orders/approve_pre_checks", WorkorderCheckController, :self_update_pre
    resources "/work_orders", WorkOrderController, except: [:new, :edit]
    get "/assets/:qr_string/get_work_orders_for_user", WorkOrderController, :index_for_user_by_qr
    get "/assets/:qr_string/get_work_requests_for_user", WorkRequestController, :index_for_user_by_qr
    resources "/workorder_tasks", WorkorderTaskController, except: [:new, :edit]
    get "/workorder_task/:id/workorder_file_upload/", WorkorderFileUploadController, :get_by_workorder_task_id
    resources "/workorder_file_uploads", WorkorderFileUploadController, except: [:new, :edit]
    post "/work_orders/:work_order_id/update_asset_status", WorkOrderController, :update_asset_status
    put "/update_workorder_tasks", WorkorderTaskController, :group_update
    get "/work_orders/:work_order_id/workorder_tasks", WorkorderTaskController, :index_by_workorder
    put "/update_work_orders", WorkOrderController, :update_multiple
    get "/workorder_status_tracks/:work_order_id", WorkorderStatusTrackController, :index
    get "/download_workorder_templates", ReferenceDownloadController, :download_workorder_templates
    post "/upload_workorder_templates", ReferenceUploadController, :upload_workorder_templates
    get "/download_workorder_schedules", ReferenceDownloadController, :download_workorder_schedules
    post "/upload_workorder_schedules", ReferenceUploadController, :upload_workorder_schedules


    resources "/org_units", OrgUnitController, except: [:new, :edit, :index]
    get "/download_org_units", ReferenceDownloadController, :download_org_units
    post "/upload_org_units", ReferenceUploadController, :upload_org_units
    get "/parties/:party_id/org_units", OrgUnitController, :index
    get "/parties/:party_id/org_units_tree", OrgUnitController, :tree
    get "/parties/:party_id/org_units/leaves", OrgUnitController, :leaves
    put "/org_units/:id/activate", OrgUnitController, :activate_org_unit
    put "/org_units/:id/deactivate", OrgUnitController, :deactivate_org_unit


    resources "/employees", EmployeeController, except: [:new, :edit]
    get "/reportees", EmployeeController, :reportees_for_logged_in_user
    get "/employees/:employee_id/reportees", EmployeeController, :reportees_for_employee
    put "/employees/:id/activate", EmployeeController, :activate_employee
    put "/employees/:id/deactivate", EmployeeController, :deactivate_employee
    get "/download_employees", ReferenceDownloadController, :download_employees
    post "/upload_employees", ReferenceUploadController, :upload_employees
    resources "/users", UserController, except: [:new, :edit]
    put "/users/change_password", UserController, :change_password
    put "/users/:id/activate", UserController, :activate_user
    put "/users/:id/deactivate", UserController, :deactivate_user
    get "/download_users", ReferenceDownloadController, :download_users
    resources "/modules", ModuleController, only: [:index, :show]
    get "/modules/:module_id/features", FeatureController, :index
    resources "/role_profiles", RoleProfileController, only: [:index, :show]
    resources "/roles", RoleController, except: [:new, :edit]
    get "/download_roles", ReferenceDownloadController, :download_roles
    put "/roles/:id/activate", RoleController, :active_role
    put "/roles/:id/deactivate", RoleController, :deactivate_role

    resources "/employee_rosters", EmployeeRosterController, except: [:new, :edit]
    get "/download_employee_rosters", ReferenceDownloadController, :download_employee_rosters
    post "/upload_employee_rosters", ReferenceUploadController, :upload_employee_rosters

    get "/sessions/current_user", SessionController, :current_user

    resources "/workrequest_categories", WorkrequestCategoryController, except: [:new, :edit]
    get "/workrequest_categories_with_helpdesk_user", WorkrequestCategoryController, :index_with_helpdesk_user
    put "/workrequest_categories/:id/activate", WorkrequestCategoryController, :activate_workrequest_category
    put "/workrequest_categories/:id/deactivate", WorkrequestCategoryController, :deactivate_workrequest_category

    get "/workrequest_categories/:workrequest_category_id/workrequest_subcategories", WorkrequestSubcategoryController, :index_for_category
    resources "/workrequest_subcategories", WorkrequestSubcategoryController, except: [:index, :new, :edit]

    resources "/category_helpdesks", CategoryHelpdeskController, except: [:new, :edit]

    get "/work_requests_for_actions", WorkRequestController, :index_for_actions
    get "/work_requests/raised", WorkRequestController, :index_for_raised_user
    get "/work_requests/assigned", WorkRequestController, :index_for_assigned_user
    get "/work_requests/approvals", WorkRequestController, :index_approval_required
    get "/work_requests/category_helpdesk", WorkRequestController, :index_tickets_of_helpdesk_user
    get "/work_requests/acknowledge", WorkRequestController, :index_for_acknowledgement

    resources "/work_requests", WorkRequestController, except: [:new, :edit]
    put "/update_work_requests", WorkRequestController, :update_multiple

    get "/work_requests/:work_request_id/attachment", WorkRequestController, :get_attachment
    # resources "/workrequest_status_tracks", WorkrequestStatusTrackController, [:new, :edit]
    get "/work_requests/:work_request_id/workrequest_status_tracks", WorkrequestStatusTrackController, :index_for_work_request

    resources "/approvals", ApprovalController, except: [:new, :edit]
    post "/approve_multiple_work_request", ApprovalController, :create_multiple_approval
    get "/work_request/:work_request_id/approvals", ApprovalController, :approvals_for_work_request

    resources "/suppliers", SupplierController, except: [:new, :edit]
    get "/download_suppliers/", ReferenceDownloadController, :download_suppliers

    resources "/supplier_items", SupplierItemController, except: [:new, :edit]
    get "/download_supplier_items", ReferenceDownloadController, :download_supplier_items

    get "/items/:item_id/suppliers", SupplierItemController, :get_suppliers_for_item
    # get "/download_items", ReferenceDownloadController, :download_items

    resources "/uoms", UOMController, except: [:new, :edit]
    get "/uoms/physical", UOMController, :index_physical
    get "/uoms/cost", UOMController, :index_cost
    get "/download_uoms", ReferenceDownloadController, :download_uoms
    post "/upload_uoms", ReferenceUploadController, :upload_uoms

    resources "/uom_conversions", UomConversionController, except: [:new, :edit]
    get "/download_uom_conversions", ReferenceDownloadController, :download_uom_conversions
    post "/uoms/convert/:value/from/:from_uom_id/to/:to_uom_id", UomConversionController, :convert
    get "/items/spares", ItemController, :index_spares
    get "/items/tools", ItemController, :index_tools
    get "/items/consumables", ItemController, :index_consumables


    resources "/items", ItemController, except: [:new, :edit]
    get "/download_items", ReferenceDownloadController, :download_items
    post "/upload_items", ReferenceUploadController, :upload_items


    resources "/inventory_locations", InventoryLocationController, except: [:new, :edit, :index]
    get "/download_inventory_locations/", ReferenceDownloadController, :download_inventory_locations
    get "/sites/:site_id/inventory_locations/", InventoryLocationController, :index

    get "/inventory_locations/:inventory_location_id/inventory_stocks", InventoryStockController, :index
    get "/items/:item_id/inventory_stocks/", InventoryStockController, :stock_for_item
    get "/inventory_locations/:inventory_location_id/inventory_transactions", InventoryTransactionController, :loc_transaction
    get "/inventory_locations/:inventory_location_id/inventory_transfers", InventoryTransferController, :loc_transfer
    get "/download_inventory_stocks/", ReferenceDownloadController, :download_inventory_stocks


    # resources "/inventory_stocks", InventoryStockController, except: [:new, :edit, :create, :update]
    get "/inventory_transaction/purchase", InventoryTransactionController, :index_by_transaction_type_purchase
    get "/inventory_transaction/issue", InventoryTransactionController, :index_by_transaction_type_issue
    get "/inventory_transaction/return", InventoryTransactionController, :index_by_transaction_type_return

    get "/inventory_locations/:inventory_location_id/inventory_transactions/purchase", InventoryTransactionController, :loc_transaction_purchase
    get "/inventory_locations/:inventory_location_id/inventory_transactions/issue", InventoryTransactionController, :loc_transaction_issue
    get "/inventory_locations/:inventory_location_id/inventory_transactions/return", InventoryTransactionController, :loc_transaction_purchase

    resources "/inventory_transactions", InventoryTransactionController, except: [:new, :edit]
    post "/inventory_transactions/inventory_list/IN", InventoryTransactionController, :create_inward_transaction_list
    post "/inventory_transactions/inventory_list/IS", InventoryTransactionController, :create_issue_transaction_list
    post "/inventory_transactions/inventory_list/PRT", InventoryTransactionController, :create_purchase_return_transaction_list
    post "/inventory_transactions/inventory_list/OUT", InventoryTransactionController, :create_out_transaction_list
    post "/inventory_transactions/inventory_list/INTR", InventoryTransactionController, :create_intr_transaction_list
    post "/inventory_transactions/inventory_list/INIS", InventoryTransactionController, :create_inis_transaction_list


    resources "/inventory_transfers", InventoryTransferController, except: [:new, :edit]

    resources "/list_of_values", ListOfValueController, except: [:new, :edit]

    get "/reports/work_orders", ReportController, :get_work_order_report
    get "/reports/workflow_report", ReportController, :get_workflow_report
    get "/reports/work_request_report", ReportController, :get_work_request_report
    get "/reports/asset_status_report", ReportController, :get_asset_status_report
    get "/reports/complaints", ReportController, :get_complaint_report
    get "/reports/inventory", ReportController, :get_inventory_report
    get "/reports/work_order_status", ReportController, :get_workorder_status_report
    get "/reports/:site_id/locations_qr_code", ReportController, :get_locations_qr
    get "/reports/:site_id/equipments_qr_code", ReportController, :get_equipments_qr
    get "/reports/download_asset_qrs", ReferenceDownloadController, :download_asset_qrs
    get "/reports/csg_report", ReportController, :get_workorder_status_report
    get "/reports/calendar/", ReportController, :get_calendar


    get "/work_orders/:work_order_id/workorder_checks/type/:check_type/", WorkorderCheckController, :index_workorder_check_by_type
    resources "/workorder_checks", WorkorderCheckController, except: [:new, :edit]
    resources "/workorder_approval_tracks", WorkorderApprovalTrackController, except: [:new, :edit]
    get "/work_orders/:work_order_id/workorder_approval_tracks/type/:approval_type", WorkorderApprovalTrackController, :index_workorder_approval_tracks_by_workorder_and_type
    put "/self_approve_workorder_checks", WorkorderCheckController, :update_work_permit_checks

    get "/mobile/work_orders", WorkOrderController, :get_work_order_for_mobile
    get "/mobile/flutter",  WorkOrderController, :get_work_orders_mobile_flutter

    # get "/mobile/work_orders_test", WorkOrderController, :get_work_order_for_mobile_test

    get "/dashboards/work_order_pie_chart", DashboardController, :get_work_order_pie_chart
    get "/dashboards/workflow_ticket_pie_chart", DashboardController, :get_workflow_ticket_pie_chart
    get "/dashboards/workflow_workorder_pie_chart", DashboardController, :get_workflow_workorder_pie_chart
    get "/dashboards/work_order_bar_chart", DashboardController, :get_work_order_bar_chart
    get "/dashboards/asset_status_pie_chart", DashboardController, :get_asset_status_pie_chart
    get "/dashboards/metering_chart", DashboardController, :get_metering_linear_chart

    get "/dashboards/energy_meter_linear_chart", DashboardController, :get_energy_meter_linear_chart
    get "/dashboards/energy_meter_speedometer", DashboardController, :get_energy_meter_speedometer
    # resources "/meter_readings", MeterReadingController, except: [:new, :edit]

    get "/sites_for_attendance", EmployeeRosterController, :index_sites_for_attendance
    get "/employees_for_attendance", EmployeeRosterController, :employees
    resources "/attendances", AttendanceController, only: [:index, :create, :show]
    resources "/attendance_references", AttendanceReferenceController, except: [:new, :edit]
    get "/attendance_reference_for_employee", AttendanceReferenceController, :get_attendance_reference_for_employee
    resources "/attendance_failure_logs", AttendanceFailureLogController, except: [:new, :edit]
    get "/employees_for_manual_attendance", EmployeeRosterController, :employees_for_manual_attendance
    resources "/manual_attendances", ManualAttendanceController, except: [:new, :edit]


    resources "/manufacturers", ManufacturerController, except: [:new, :edit]
    resources "/vendors", VendorController, except: [:new, :edit]

    resources "/service_branches", ServiceBranchController, except: [:new, :edit]
    get "/vendors/:vendor_id/service_branches", ServiceBranchController, :index_by_vendor_id
    get "/manufacturers/:manufacturer_id/service_branches", ServiceBranchController, :index_by_manufacturer_id

    resources "/equipment_manufacturers", EquipmentManufacturerController, except: [:new, :edit]
    get "/equipments/:equipment_id/equipment_manufacturers", EquipmentManufacturerController, :index_by_equipment_id

    resources "/equipment_dlp_vendors", EquipmentDlpVendorController, except: [:new, :edit]
    get "/equipments/:equipment_id/equipment_dpl_vendors", EquipmentDlpVendorController, :index_by_equipment_id

    resources "/equipment_maintenance_vendors", EquipmentMaintenanceVendorController, except: [:new, :edit]
    get "/equipments/:equipment_id/equipment_maintenance_vendors", EquipmentMaintenanceVendorController, :index_by_equipment_id

    resources "/equipment_insurance_vendors", EquipmentInsuranceVendorController, except: [:new, :edit]
    get "/equipments/:equipment_id/equipment_insurance_vendors", EquipmentInsuranceVendorController, :index_by_equipment_id

    resources "/equipment_attachments", EquipmentAttachmentController, only: [:create, :show, :delete]
    get "/equipments/:equipment_id/equipment_attachments", EquipmentAttachmentController, :list_for_equipment
    get "/equipment_attachment_download/:id", EquipmentAttachmentController, :get_attachment


    resources "/uom_categories", UomCategoryController, except: [:new, :edit, :delete]

    resources "/unit_of_measurements", UnitOfMeasurementController, except: [:new, :edit]
    get "/uom_categories/:uom_category_id/unit_of_measurements", UnitOfMeasurementController, :index_by_uom_category

    resources "/stores", StoreController, except: [:new, :edit]
    get "/sites/:site_id/stores", StoreController, :index_by_site

    resources "/inventory_suppliers", InventorySupplierController, except: [:new, :edit]

    resources "/inventory_items", InventoryItemController, except: [:new, :edit]
  end
end
