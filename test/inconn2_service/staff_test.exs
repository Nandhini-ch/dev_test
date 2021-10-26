defmodule Inconn2Service.StaffTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Staff

  describe "org_units" do
    alias Inconn2Service.Staff.OrgUnit

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def org_unit_fixture(attrs \\ %{}) do
      {:ok, org_unit} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Staff.create_org_unit()

      org_unit
    end

    test "list_org_units/0 returns all org_units" do
      org_unit = org_unit_fixture()
      assert Staff.list_org_units() == [org_unit]
    end

    test "get_org_unit!/1 returns the org_unit with given id" do
      org_unit = org_unit_fixture()
      assert Staff.get_org_unit!(org_unit.id) == org_unit
    end

    test "create_org_unit/1 with valid data creates a org_unit" do
      assert {:ok, %OrgUnit{} = org_unit} = Staff.create_org_unit(@valid_attrs)
      assert org_unit.name == "some name"
    end

    test "create_org_unit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_org_unit(@invalid_attrs)
    end

    test "update_org_unit/2 with valid data updates the org_unit" do
      org_unit = org_unit_fixture()
      assert {:ok, %OrgUnit{} = org_unit} = Staff.update_org_unit(org_unit, @update_attrs)
      assert org_unit.name == "some updated name"
    end

    test "update_org_unit/2 with invalid data returns error changeset" do
      org_unit = org_unit_fixture()
      assert {:error, %Ecto.Changeset{}} = Staff.update_org_unit(org_unit, @invalid_attrs)
      assert org_unit == Staff.get_org_unit!(org_unit.id)
    end

    test "delete_org_unit/1 deletes the org_unit" do
      org_unit = org_unit_fixture()
      assert {:ok, %OrgUnit{}} = Staff.delete_org_unit(org_unit)
      assert_raise Ecto.NoResultsError, fn -> Staff.get_org_unit!(org_unit.id) end
    end

    test "change_org_unit/1 returns a org_unit changeset" do
      org_unit = org_unit_fixture()
      assert %Ecto.Changeset{} = Staff.change_org_unit(org_unit)
    end
  end

  describe "employees" do
    alias Inconn2Service.Staff.Employee

    @valid_attrs %{Emp_id: "some Emp_id", Landline_no: "some Landline_no", Mobile_no: "some Mobile_no", Salary: 120.5, designation: "some designation", email: "some email", employement_start_date: ~D[2010-04-17], employment_end_date: ~D[2010-04-17], first_name: "some first_name", has_login_credentials: true, last_name: "some last_name"}
    @update_attrs %{Emp_id: "some updated Emp_id", Landline_no: "some updated Landline_no", Mobile_no: "some updated Mobile_no", Salary: 456.7, designation: "some updated designation", email: "some updated email", employement_start_date: ~D[2011-05-18], employment_end_date: ~D[2011-05-18], first_name: "some updated first_name", has_login_credentials: false, last_name: "some updated last_name"}
    @invalid_attrs %{Emp_id: nil, Landline_no: nil, Mobile_no: nil, Salary: nil, designation: nil, email: nil, employement_start_date: nil, employment_end_date: nil, first_name: nil, has_login_credentials: nil, last_name: nil}

    def employee_fixture(attrs \\ %{}) do
      {:ok, employee} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Staff.create_employee()

      employee
    end

    test "list_employees/0 returns all employees" do
      employee = employee_fixture()
      assert Staff.list_employees() == [employee]
    end

    test "get_employee!/1 returns the employee with given id" do
      employee = employee_fixture()
      assert Staff.get_employee!(employee.id) == employee
    end

    test "create_employee/1 with valid data creates a employee" do
      assert {:ok, %Employee{} = employee} = Staff.create_employee(@valid_attrs)
      assert employee.Emp_id == "some Emp_id"
      assert employee.Landline_no == "some Landline_no"
      assert employee.Mobile_no == "some Mobile_no"
      assert employee.Salary == 120.5
      assert employee.designation == "some designation"
      assert employee.email == "some email"
      assert employee.employement_start_date == ~D[2010-04-17]
      assert employee.employment_end_date == ~D[2010-04-17]
      assert employee.first_name == "some first_name"
      assert employee.has_login_credentials == true
      assert employee.last_name == "some last_name"
    end

    test "create_employee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_employee(@invalid_attrs)
    end

    test "update_employee/2 with valid data updates the employee" do
      employee = employee_fixture()
      assert {:ok, %Employee{} = employee} = Staff.update_employee(employee, @update_attrs)
      assert employee.Emp_id == "some updated Emp_id"
      assert employee.Landline_no == "some updated Landline_no"
      assert employee.Mobile_no == "some updated Mobile_no"
      assert employee.Salary == 456.7
      assert employee.designation == "some updated designation"
      assert employee.email == "some updated email"
      assert employee.employement_start_date == ~D[2011-05-18]
      assert employee.employment_end_date == ~D[2011-05-18]
      assert employee.first_name == "some updated first_name"
      assert employee.has_login_credentials == false
      assert employee.last_name == "some updated last_name"
    end

    test "update_employee/2 with invalid data returns error changeset" do
      employee = employee_fixture()
      assert {:error, %Ecto.Changeset{}} = Staff.update_employee(employee, @invalid_attrs)
      assert employee == Staff.get_employee!(employee.id)
    end

    test "delete_employee/1 deletes the employee" do
      employee = employee_fixture()
      assert {:ok, %Employee{}} = Staff.delete_employee(employee)
      assert_raise Ecto.NoResultsError, fn -> Staff.get_employee!(employee.id) end
    end

    test "change_employee/1 returns a employee changeset" do
      employee = employee_fixture()
      assert %Ecto.Changeset{} = Staff.change_employee(employee)
    end
  end

  describe "users" do
    alias Inconn2Service.Staff.User

    @valid_attrs %{password: "some password", role_id: [], username: "some username"}
    @update_attrs %{password: "some updated password", role_id: [], username: "some updated username"}
    @invalid_attrs %{password: nil, role_id: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Staff.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Staff.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Staff.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Staff.create_user(@valid_attrs)
      assert user.password == "some password"
      assert user.role_id == []
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Staff.update_user(user, @update_attrs)
      assert user.password == "some updated password"
      assert user.role_id == []
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Staff.update_user(user, @invalid_attrs)
      assert user == Staff.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Staff.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Staff.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Staff.change_user(user)
    end
  end

  describe "roles" do
    alias Inconn2Service.Staff.Role

    @valid_attrs %{code: "some code", name: "some name"}
    @update_attrs %{code: "some updated code", name: "some updated name"}
    @invalid_attrs %{code: nil, name: nil}

    def role_fixture(attrs \\ %{}) do
      {:ok, role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Staff.create_role()

      role
    end

    test "list_roles/0 returns all roles" do
      role = role_fixture()
      assert Staff.list_roles() == [role]
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert Staff.get_role!(role.id) == role
    end

    test "create_role/1 with valid data creates a role" do
      assert {:ok, %Role{} = role} = Staff.create_role(@valid_attrs)
      assert role.code == "some code"
      assert role.name == "some name"
    end

    test "create_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_role(@invalid_attrs)
    end

    test "update_role/2 with valid data updates the role" do
      role = role_fixture()
      assert {:ok, %Role{} = role} = Staff.update_role(role, @update_attrs)
      assert role.code == "some updated code"
      assert role.name == "some updated name"
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = role_fixture()
      assert {:error, %Ecto.Changeset{}} = Staff.update_role(role, @invalid_attrs)
      assert role == Staff.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      role = role_fixture()
      assert {:ok, %Role{}} = Staff.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Staff.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      role = role_fixture()
      assert %Ecto.Changeset{} = Staff.change_role(role)
    end
  end

  describe "features" do
    alias Inconn2Service.Staff.Feature

    @valid_attrs %{code: "some code", description: "some description", name: "some name"}
    @update_attrs %{code: "some updated code", description: "some updated description", name: "some updated name"}
    @invalid_attrs %{code: nil, description: nil, name: nil}

    def feature_fixture(attrs \\ %{}) do
      {:ok, feature} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Staff.create_feature()

      feature
    end

    test "list_features/0 returns all features" do
      feature = feature_fixture()
      assert Staff.list_features() == [feature]
    end

    test "get_feature!/1 returns the feature with given id" do
      feature = feature_fixture()
      assert Staff.get_feature!(feature.id) == feature
    end

    test "create_feature/1 with valid data creates a feature" do
      assert {:ok, %Feature{} = feature} = Staff.create_feature(@valid_attrs)
      assert feature.code == "some code"
      assert feature.description == "some description"
      assert feature.name == "some name"
    end

    test "create_feature/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_feature(@invalid_attrs)
    end

    test "update_feature/2 with valid data updates the feature" do
      feature = feature_fixture()
      assert {:ok, %Feature{} = feature} = Staff.update_feature(feature, @update_attrs)
      assert feature.code == "some updated code"
      assert feature.description == "some updated description"
      assert feature.name == "some updated name"
    end

    test "update_feature/2 with invalid data returns error changeset" do
      feature = feature_fixture()
      assert {:error, %Ecto.Changeset{}} = Staff.update_feature(feature, @invalid_attrs)
      assert feature == Staff.get_feature!(feature.id)
    end

    test "delete_feature/1 deletes the feature" do
      feature = feature_fixture()
      assert {:ok, %Feature{}} = Staff.delete_feature(feature)
      assert_raise Ecto.NoResultsError, fn -> Staff.get_feature!(feature.id) end
    end

    test "change_feature/1 returns a feature changeset" do
      feature = feature_fixture()
      assert %Ecto.Changeset{} = Staff.change_feature(feature)
    end
  end
end
