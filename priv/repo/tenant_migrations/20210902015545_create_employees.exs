defmodule Inconn2Service.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    create table(:employees) do
      add :first_name, :string
      add :last_name, :string
      add :employment_start_date, :date
      add :employment_end_date, :date
      add :designation, :string
      add :email, :string
      add :employee_id, :string
      add :landline_no, :string
      add :mobile_no, :string
      add :salary, :float
      add :has_login_credentials, :boolean, default: false, null: false
      add :reports_to, :string
      add :skills, {:array, :integer}
      add :org_unit_id, references(:org_units, on_delete: :nothing)
      add :party_id, references(:parties, on_delete: :nothing)
      add :active, :boolean
      timestamps()
    end

    create index(:employees, [:org_unit_id])
    create unique_index(:employees, [:employee_id])
    create unique_index(:employees, [:email])
    create index(:employees, [:party_id])
  end
end
