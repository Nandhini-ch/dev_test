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

    @valid_attrs %{Emp_id: "some Emp_id", Landline_no: "some Landline_no", Mobile_no: "some Mobile_no", Salary: 120.5, designation: "some designation", email: "some email", employment_start_date: ~D[2010-04-17], employment_end_date: ~D[2010-04-17], first_name: "some first_name", has_login_credentials: true, last_name: "some last_name"}
    @update_attrs %{Emp_id: "some updated Emp_id", Landline_no: "some updated Landline_no", Mobile_no: "some updated Mobile_no", Salary: 456.7, designation: "some updated designation", email: "some updated email", employment_start_date: ~D[2011-05-18], employment_end_date: ~D[2011-05-18], first_name: "some updated first_name", has_login_credentials: false, last_name: "some updated last_name"}
    @invalid_attrs %{Emp_id: nil, Landline_no: nil, Mobile_no: nil, Salary: nil, designation: nil, email: nil, employment_start_date: nil, employment_end_date: nil, first_name: nil, has_login_credentials: nil, last_name: nil}

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
      assert employee.employment_start_date == ~D[2010-04-17]
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
      assert employee.employment_start_date == ~D[2011-05-18]
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
      assert user.role_ids == []
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Staff.update_user(user, @update_attrs)
      assert user.password == "some updated password"
      assert user.role_ids == []
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

  describe "modules" do
    alias Inconn2Service.Staff.Module

    @valid_attrs %{feature_ids: [], name: "some name"}
    @update_attrs %{feature_ids: [], name: "some updated name"}
    @invalid_attrs %{feature_ids: nil, name: nil}

    def module_fixture(attrs \\ %{}) do
      {:ok, module} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Staff.create_module()

      module
    end

    test "list_modules/0 returns all modules" do
      module = module_fixture()
      assert Staff.list_modules() == [module]
    end

    test "get_module!/1 returns the module with given id" do
      module = module_fixture()
      assert Staff.get_module!(module.id) == module
    end

    test "create_module/1 with valid data creates a module" do
      assert {:ok, %Module{} = module} = Staff.create_module(@valid_attrs)
      assert module.feature_ids == []
      assert module.name == "some name"
    end

    test "create_module/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_module(@invalid_attrs)
    end

    test "update_module/2 with valid data updates the module" do
      module = module_fixture()
      assert {:ok, %Module{} = module} = Staff.update_module(module, @update_attrs)
      assert module.feature_ids == []
      assert module.name == "some updated name"
    end

    test "update_module/2 with invalid data returns error changeset" do
      module = module_fixture()
      assert {:error, %Ecto.Changeset{}} = Staff.update_module(module, @invalid_attrs)
      assert module == Staff.get_module!(module.id)
    end

    test "delete_module/1 deletes the module" do
      module = module_fixture()
      assert {:ok, %Module{}} = Staff.delete_module(module)
      assert_raise Ecto.NoResultsError, fn -> Staff.get_module!(module.id) end
    end

    test "change_module/1 returns a module changeset" do
      module = module_fixture()
      assert %Ecto.Changeset{} = Staff.change_module(module)
    end
  end

  describe "role_profiles" do
    alias Inconn2Service.Staff.RoleProfile

    @valid_attrs %{code: "some code", feature_ids: [], label: "some label"}
    @update_attrs %{code: "some updated code", feature_ids: [], label: "some updated label"}
    @invalid_attrs %{code: nil, feature_ids: nil, label: nil}

    def role_profile_fixture(attrs \\ %{}) do
      {:ok, role_profile} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Staff.create_role_profile()

      role_profile
    end

    test "list_role_profiles/0 returns all role_profiles" do
      role_profile = role_profile_fixture()
      assert Staff.list_role_profiles() == [role_profile]
    end

    test "get_role_profile!/1 returns the role_profile with given id" do
      role_profile = role_profile_fixture()
      assert Staff.get_role_profile!(role_profile.id) == role_profile
    end

    test "create_role_profile/1 with valid data creates a role_profile" do
      assert {:ok, %RoleProfile{} = role_profile} = Staff.create_role_profile(@valid_attrs)
      assert role_profile.code == "some code"
      assert role_profile.feature_ids == []
      assert role_profile.label == "some label"
    end

    test "create_role_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_role_profile(@invalid_attrs)
    end

    test "update_role_profile/2 with valid data updates the role_profile" do
      role_profile = role_profile_fixture()
      assert {:ok, %RoleProfile{} = role_profile} = Staff.update_role_profile(role_profile, @update_attrs)
      assert role_profile.code == "some updated code"
      assert role_profile.feature_ids == []
      assert role_profile.label == "some updated label"
    end

    test "update_role_profile/2 with invalid data returns error changeset" do
      role_profile = role_profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Staff.update_role_profile(role_profile, @invalid_attrs)
      assert role_profile == Staff.get_role_profile!(role_profile.id)
    end

    test "delete_role_profile/1 deletes the role_profile" do
      role_profile = role_profile_fixture()
      assert {:ok, %RoleProfile{}} = Staff.delete_role_profile(role_profile)
      assert_raise Ecto.NoResultsError, fn -> Staff.get_role_profile!(role_profile.id) end
    end

    test "change_role_profile/1 returns a role_profile changeset" do
      role_profile = role_profile_fixture()
      assert %Ecto.Changeset{} = Staff.change_role_profile(role_profile)
    end
  end

  describe "designations" do
    alias Inconn2Service.Staff.Designation

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def designation_fixture(attrs \\ %{}) do
      {:ok, designation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Staff.create_designation()

      designation
    end

    test "list_designations/0 returns all designations" do
      designation = designation_fixture()
      assert Staff.list_designations() == [designation]
    end

    test "get_designation!/1 returns the designation with given id" do
      designation = designation_fixture()
      assert Staff.get_designation!(designation.id) == designation
    end

    test "create_designation/1 with valid data creates a designation" do
      assert {:ok, %Designation{} = designation} = Staff.create_designation(@valid_attrs)
      assert designation.description == "some description"
      assert designation.name == "some name"
    end

    test "create_designation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_designation(@invalid_attrs)
    end

    test "update_designation/2 with valid data updates the designation" do
      designation = designation_fixture()
      assert {:ok, %Designation{} = designation} = Staff.update_designation(designation, @update_attrs)
      assert designation.description == "some updated description"
      assert designation.name == "some updated name"
    end

    test "update_designation/2 with invalid data returns error changeset" do
      designation = designation_fixture()
      assert {:error, %Ecto.Changeset{}} = Staff.update_designation(designation, @invalid_attrs)
      assert designation == Staff.get_designation!(designation.id)
    end

    test "delete_designation/1 deletes the designation" do
      designation = designation_fixture()
      assert {:ok, %Designation{}} = Staff.delete_designation(designation)
      assert_raise Ecto.NoResultsError, fn -> Staff.get_designation!(designation.id) end
    end

    test "change_designation/1 returns a designation changeset" do
      designation = designation_fixture()
      assert %Ecto.Changeset{} = Staff.change_designation(designation)
    end
  end

  describe "teams" do
    alias Inconn2Service.Staff.Team

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def team_fixture(attrs \\ %{}) do
      {:ok, team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Staff.create_team()

      team
    end

    test "list_teams/0 returns all teams" do
      team = team_fixture()
      assert Staff.list_teams() == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Staff.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      assert {:ok, %Team{} = team} = Staff.create_team(@valid_attrs)
      assert team.description == "some description"
      assert team.name == "some name"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      assert {:ok, %Team{} = team} = Staff.update_team(team, @update_attrs)
      assert team.description == "some updated description"
      assert team.name == "some updated name"
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = Staff.update_team(team, @invalid_attrs)
      assert team == Staff.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = Staff.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Staff.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Staff.change_team(team)
    end
  end

  describe "team_members" do
    alias Inconn2Service.Staff.TeamMember

    @valid_attrs %{employee_id: 42}
    @update_attrs %{employee_id: 43}
    @invalid_attrs %{employee_id: nil}

    def team_member_fixture(attrs \\ %{}) do
      {:ok, team_member} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Staff.create_team_member()

      team_member
    end

    test "list_team_members/0 returns all team_members" do
      team_member = team_member_fixture()
      assert Staff.list_team_members() == [team_member]
    end

    test "get_team_member!/1 returns the team_member with given id" do
      team_member = team_member_fixture()
      assert Staff.get_team_member!(team_member.id) == team_member
    end

    test "create_team_member/1 with valid data creates a team_member" do
      assert {:ok, %TeamMember{} = team_member} = Staff.create_team_member(@valid_attrs)
      assert team_member.employee_id == 42
    end

    test "create_team_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_team_member(@invalid_attrs)
    end

    test "update_team_member/2 with valid data updates the team_member" do
      team_member = team_member_fixture()
      assert {:ok, %TeamMember{} = team_member} = Staff.update_team_member(team_member, @update_attrs)
      assert team_member.employee_id == 43
    end

    test "update_team_member/2 with invalid data returns error changeset" do
      team_member = team_member_fixture()
      assert {:error, %Ecto.Changeset{}} = Staff.update_team_member(team_member, @invalid_attrs)
      assert team_member == Staff.get_team_member!(team_member.id)
    end

    test "delete_team_member/1 deletes the team_member" do
      team_member = team_member_fixture()
      assert {:ok, %TeamMember{}} = Staff.delete_team_member(team_member)
      assert_raise Ecto.NoResultsError, fn -> Staff.get_team_member!(team_member.id) end
    end

    test "change_team_member/1 returns a team_member changeset" do
      team_member = team_member_fixture()
      assert %Ecto.Changeset{} = Staff.change_team_member(team_member)
    end
  end
end
