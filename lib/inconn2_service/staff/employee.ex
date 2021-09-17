defmodule Inconn2Service.Staff.Employee do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Staff.OrgUnit
  import EctoCommons.EmailValidator
  alias Inconn2Service.AssetConfig.Party

  schema "employees" do
    field :employee_id, :string
    field :landline_no, :string
    field :mobile_no, :string
    field :salary, :float
    field :designation, :string
    field :email, :string
    field :employement_start_date, :date
    field :employment_end_date, :date
    field :first_name, :string
    field :has_login_credentials, :boolean, default: false
    field :last_name, :string
    field :reports_to, :string
    field :skills, {:array, :integer}
    belongs_to :org_unit, OrgUnit
    belongs_to :party, Party

    timestamps()
  end

  @doc false
  def changeset(employee, attrs) do
    employee
    |> cast(attrs, [
      :first_name,
      :last_name,
      :employement_start_date,
      :employment_end_date,
      :designation,
      :email,
      :employee_id,
      :landline_no,
      :mobile_no,
      :salary,
      :has_login_credentials,
      :reports_to,
      :skills,
      :org_unit_id,
      :party_id
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :designation,
      :email,
      :employee_id,
      :mobile_no,
      :has_login_credentials,
      :skills,
      :org_unit_id,
      :party_id
    ])
    |> validate_email(:email, checks: [:html_input, :pow])
    |> unique_constraint(:employee_id)
    |> unique_constraint(:email)
    #  |> unique_constraint(:name, name: :index_holidays_dates)
    # unique_constraint(:name, name: :index_shifts_dates)
    |> assoc_constraint(:org_unit)
    |> assoc_constraint(:party)
  end
end
