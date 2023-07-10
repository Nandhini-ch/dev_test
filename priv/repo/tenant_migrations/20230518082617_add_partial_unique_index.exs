defmodule Inconn2Service.Repo.Migrations.AddPartialUniqueIndex do
  use Ecto.Migration

  def change do
    drop_if_exists index("alert_notification_configs", [:site_id])
    drop index("shifts", [:site_id, :start_date, :end_date, :start_time, :end_time, :applicable_days], name: :index_shifts_dates)

    create unique_index(:alert_notification_configs, [:site_id, :alert_notification_reserve_id], where: "active = 'true'", name: :unique_alert_config)
    create unique_index(:designations, [:name], where: "active = 'true'", name: :unique_designations)
    create unique_index(:roles, [:name], where: "active = 'true'", name: :unique_roles)
    create unique_index(:shifts, [:code], where: "active = 'true'", name: :unique_shifts)
    create unique_index(:sites, [:site_code], where: "active = 'true'", name: :unique_sites)
    create unique_index(:locations, [:location_code], where: "active = 'true'", name: :unique_locations)
    create unique_index(:equipments, [:equipment_code], where: "active = 'true'", name: :unique_equipments)
    create unique_index(:uoms, [:name], where: "active = 'true'", name: :unique_uoms)
    create unique_index(:category_helpdesks, [:site_id, :user_id, :workrequest_category_id], where: "active = 'true'", name: :unique_category_helpdesks)
    create unique_index(:employees, [:employee_id], where: "active = 'true'", name: :unique_employees)
  end
end
