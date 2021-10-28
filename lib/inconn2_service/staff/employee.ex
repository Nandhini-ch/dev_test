defmodule Inconn2Service.Staff.Employee do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.Staff.OrgUnit
  alias Inconn2Service.AssetConfig.Party

  schema "employees" do
    field :employee_id, :string
    field :landline_no, :string
    field :mobile_no, :string
    field :salary, :float
    field :designation, :string
    field :email, :string
    field :employment_start_date, :date
    field :employment_end_date, :date
    field :first_name, :string
    field :has_login_credentials, :boolean
    field :last_name, :string
    field :reports_to, :string
    field :skills, {:array, :integer}
    belongs_to :org_unit, OrgUnit
    belongs_to :party, Party
    field :role_ids, {:array, :integer}, virtual: true

    timestamps()
  end

  @doc false
  def changeset(employee, attrs) do
    employee
    |> cast(attrs, [
      :first_name,
      :last_name,
      :employment_start_date,
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
      :party_id,
      :role_ids
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :designation,
      :employee_id,
      :mobile_no,
      :has_login_credentials,
      :org_unit_id,
      :party_id
    ])
    |> unique_constraint(:employee_id)
    |> unique_constraint(:email)
    |> validate_login()
    |> validate_format(:email, ~r/@/)
    |> assoc_constraint(:org_unit)
    |> assoc_constraint(:party)
  end

  defp validate_login(cs) do
    case get_field(cs, :has_login_credentials, false) do
      true -> validate_required(cs, [:role_ids, :email])
      false -> cs
    end
  end

end
