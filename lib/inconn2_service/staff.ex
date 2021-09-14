defmodule Inconn2Service.Staff do
  @moduledoc """
  The Staff context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Ecto.Multi
  alias Inconn2Service.Repo

  alias Inconn2Service.Staff.OrgUnit
  alias Inconn2Service.Util.HierarchyManager
  import Comeonin
  alias Inconn2Service.AssetConfig.Party
  alias Inconn2Service.Staff.Role

  @doc """
  Returns the list of org_units.

  ## Examples

      iex> list_org_units()
      [%OrgUnit{}, ...]

  """
  def list_org_units(party_id, prefix) do
    OrgUnit
    |> where(party_id: ^party_id)
    |> Repo.all(prefix: prefix)
  end

  def list_org_units_tree(party_id, prefix) do
    list_org_units(party_id, prefix)
    |> HierarchyManager.build_tree()
  end

  def list_org_units_leaves(party_id, prefix) do
    ids =
      list_org_units(party_id, prefix)
      |> HierarchyManager.leaf_nodes()
      |> MapSet.to_list()

    from(o in OrgUnit, where: o.id in ^ids) |> Repo.all(prefix: prefix)
  end

  @doc """
  Gets a single org_unit.

  Raises `Ecto.NoResultsError` if the Org unit does not exist.

  ## Examples

      iex> get_org_unit!(123)
      %OrgUnit{}

      iex> get_org_unit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_org_unit!(id, prefix), do: Repo.get!(OrgUnit, id, prefix: prefix)

  def get_root_org_units(party_id, prefix) do
    root_path = []

    query =
      from(o in OrgUnit,
        where: fragment("(?) = ?", field(o, :path), ^root_path) and o.party_id == ^party_id
      )

    Repo.all(query, prefix: prefix)
  end

  def get_parent_of_org_unit(org_unit_id, prefix) do
    ou = get_org_unit!(org_unit_id, prefix)
    HierarchyManager.parent(ou) |> Repo.one(prefix: prefix)
  end

  @doc """
  Creates a org_unit.

  ## Examples

      iex> create_org_unit(%{field: value})
      {:ok, %OrgUnit{}}

      iex> create_org_unit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_org_unit(attrs \\ %{}, prefix) do
    parent_id = Map.get(attrs, "parent_id", nil)

    ou_cs =
      %OrgUnit{}
      |> OrgUnit.changeset(attrs)

    if parent_id != nil do
      ou_cs = check_parent_party(parent_id, ou_cs, prefix)
      create_org_unit_in_tree(parent_id, ou_cs, prefix)
    else
      create_org_unit_in_tree(parent_id, ou_cs, prefix)
    end
  end

  defp create_org_unit_in_tree(nil, ou_cs, prefix) do
    Repo.insert(ou_cs, prefix: prefix)
  end

  defp create_org_unit_in_tree(parent_id, ou_cs, prefix) do
    case Repo.get(OrgUnit, parent_id, prefix: prefix) do
      nil ->
        add_error(ou_cs, :parent_id, "Parent object does not exist")
        |> Repo.insert(prefix: prefix)

      parent ->
        ou_cs
        |> HierarchyManager.make_child_of(parent)
        |> Repo.insert(prefix: prefix)
    end
  end

  defp check_parent_party(nil, ou_cs, prefix) do
    parent_id = get_field(ou_cs, :parent_id, nil)

    case parent_id do
      nil ->
        ou_cs

      _ ->
        parent = Repo.get(OrgUnit, parent_id, prefix: prefix)
        party_id = get_field(ou_cs, :party_id)

        if parent.party_id == party_id do
          ou_cs
        else
          add_error(ou_cs, :parent_id, "Party id of parent is different")
        end
    end
  end

  defp check_parent_party(parent_id, ou_cs, prefix) do
    party_id = get_field(ou_cs, :party_id)

    case Repo.get(OrgUnit, parent_id, prefix: prefix) do
      nil ->
        ou_cs

      parent ->
        if parent.party_id == party_id do
          ou_cs
        else
          add_error(ou_cs, :parent_id, "Party id of parent is different")
        end
    end
  end

  @doc """
  Updates a org_unit.

  ## Examples

      iex> update_org_unit(org_unit, %{field: new_value})
      {:ok, %OrgUnit{}}

      iex> update_org_unit(org_unit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_org_unit(%OrgUnit{} = org_unit, attrs, prefix) do
    existing_parent_id = HierarchyManager.parent_id(org_unit)

    cond do
      Map.has_key?(attrs, "parent_id") and attrs["parent_id"] != existing_parent_id ->
        new_parent_id = attrs["parent_id"]

        ou_cs = update_org_unit_default_changeset_pipe(org_unit, attrs, prefix)
        ou_cs = check_parent_party(new_parent_id, ou_cs, prefix)
        update_org_unit_in_tree(new_parent_id, ou_cs, org_unit, prefix)

      true ->
        ou_cs = update_org_unit_default_changeset_pipe(org_unit, attrs, prefix)
        ou_cs = check_parent_party(existing_parent_id, ou_cs, prefix)
        Repo.update(ou_cs, prefix: prefix)
    end
  end

  defp update_org_unit_in_tree(nil, ou_cs, org_unit, prefix) do
    descendents = HierarchyManager.descendants(org_unit) |> Repo.all(prefix: prefix)
    # adjust the path (from old path to new path )for all descendents
    ou_cs = change(ou_cs, %{path: []})
    make_org_units_changeset_and_update(ou_cs, org_unit, descendents, [], prefix)
  end

  defp update_org_unit_in_tree(new_parent_id, ou_cs, org_unit, prefix) do
    # Get the new parent and check
    case Repo.get(OrgUnit, new_parent_id, prefix: prefix) do
      nil ->
        add_error(ou_cs, :parent_id, "New parent object does not exist")
        |> Repo.insert(prefix: prefix)

      parent ->
        # Get the descendents
        descendents = HierarchyManager.descendants(org_unit) |> Repo.all(prefix: prefix)
        new_path = parent.path ++ [parent.id]
        # make this node child of new parent
        head_cs = HierarchyManager.make_child_of(ou_cs, parent)
        make_org_units_changeset_and_update(head_cs, org_unit, descendents, new_path, prefix)
    end
  end

  defp make_org_units_changeset_and_update(head_cs, org_unit, descendents, new_path, prefix) do
    # adjust the path (from old path to ne path )for all descendents
    multi =
      [
        {org_unit.id, head_cs}
        | Enum.map(descendents, fn d ->
            {_, rest} = Enum.split_while(d.path, fn e -> e != org_unit.id end)
            {d.id, OrgUnit.changeset(d, %{}) |> change(%{path: new_path ++ rest})}
          end)
      ]
      |> Enum.reduce(Multi.new(), fn {indx, cs}, multi ->
        Multi.update(multi, :"org_unit#{indx}", cs, prefix: prefix)
      end)

    case Repo.transaction(multi, prefix: prefix) do
      {:ok, ou} -> {:ok, Map.get(ou, :"org_unit#{org_unit.id}")}
      _ -> {:error, head_cs}
    end
  end

  defp update_org_unit_default_changeset_pipe(%OrgUnit{} = org_unit, attrs, _prefix) do
    org_unit
    |> OrgUnit.changeset(attrs)
  end

  @doc """
  Deletes a org_unit.

  ## Examples

      iex> delete_org_unit(org_unit)
      {:ok, %OrgUnit{}}

      iex> delete_org_unit(org_unit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_org_unit(%OrgUnit{} = org_unit, prefix) do
    # Deletes the org_unit and children forcibly
    # TBD: do not allow delete if this org_unit is linked to some other record(s)
    # Add that validation here....
    subtree = HierarchyManager.subtree(org_unit)
    Repo.delete_all(subtree, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking org_unit changes.

  ## Examples

      iex> change_org_unit(org_unit)
      %Ecto.Changeset{data: %OrgUnit{}}

  """
  def change_org_unit(%OrgUnit{} = org_unit, attrs \\ %{}) do
    OrgUnit.changeset(org_unit, attrs)
  end

  alias Inconn2Service.Staff.Employee

  @doc """
  Returns the list of employees.

  ## Examples

      iex> list_employees()
      [%Employee{}, ...]

  """
  def list_employees do
    Repo.all(Employee)
  end

  @doc """
  Gets a single employee.

  Raises `Ecto.NoResultsError` if the Employee does not exist.

  ## Examples

      iex> get_employee!(123)
      %Employee{}

      iex> get_employee!(456)
      ** (Ecto.NoResultsError)

  """
  def get_employee!(id, prefix), do: Repo.get!(Employee, id, prefix: prefix)

  def get_employee_email!(email, prefix) do
    query =
      from(e in Employee,
        where: e.email == ^email
      )

    IO.inspect(Repo.one(query, prefix: prefix))
  end

  @doc """
  Creates a employee.

  ## Examples

      iex> create_employee(%{field: value})
      {:ok, %Employee{}}

      iex> create_employee(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_employee(attrs \\ %{}, prefix) do
    has_login_credentials = Map.get(attrs, "has_login_credentials", false)

    if has_login_credentials == true do
      employee_set =
        %Employee{}
        |> Employee.changeset(attrs)
        |> Repo.insert(prefix: prefix)

      case employee_set do
        {:ok, emp_set} ->
          case create_user(attrs, prefix) do
            {:ok, _change_set} ->
              IO.inspect(emp_set)

            {:error, change_set} ->
              IO.inspect(change_set)

            changeset ->
              IO.inspect(changeset)
          end

        {:error, change_set} ->
          IO.inspect(change_set)
      end
    end

    if has_login_credentials == false do
      employee_set =
        %Employee{}
        |> Employee.changeset(attrs)
        |> Repo.insert(prefix: prefix)

      case employee_set do
        {:ok, emp_set} ->
          IO.inspect(emp_set)

        {:error, change_set} ->
          IO.inspect(change_set)
      end
    end
  end

  @doc """
  Updates a employee.

  ## Examples

      iex> update_employee(employee, %{field: new_value})
      {:ok, %Employee{}}

      iex> update_employee(employee, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_employee(%Employee{} = employee, attrs, prefix) do
    employee
    |> Employee.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a employee.

  ## Examples

      iex> delete_employee(employee)
      {:ok, %Employee{}}

      iex> delete_employee(employee)
      {:error, %Ecto.Changeset{}}

  """
  def delete_employee(%Employee{} = employee, prefix) do
    Repo.delete(employee, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking employee changes.

  ## Examples

      iex> change_employee(employee)
      %Ecto.Changeset{data: %Employee{}}

  """
  def change_employee(%Employee{} = employee, attrs \\ %{}) do
    Employee.changeset(employee, attrs)
  end

  alias Inconn2Service.Staff.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users(prefix) do
    Repo.all(User, prefix: prefix)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id, prefix), do: Repo.get!(User, id, prefix: prefix)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}, prefix) do
    # Check to see if create_employee has called this method or directly create_user is called
    # If the call is from employee then email from employee is set as username here
    # The password is defaulted to password#1234
    has_email = Map.get(attrs, "email", nil)
    IO.inspect(has_email)
    # check_licensee(party_type)

    returnMap = %{
      "username" => has_email,
      "password" => "password#1234",
      "role_id" => [1]
    }

    if(has_email != nil) do
      %User{}
      |> User.changeset(returnMap)
      |> Repo.insert(prefix: prefix)
    end

    if has_email == nil do
      %User{}
      |> User.changeset(attrs)
      |> Repo.insert(prefix: prefix)
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs, prefix) do
    user
    |> User.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user, prefix) do
    Repo.delete(user, prefix: prefix)
  end

  def get_user_by_email(email, prefix) do
    # pass_hash_map = Argon2.add_hash(password)
    # pass_hash = Map.get(pass_hash_map, :password_hash)

    query =
      from(u in User,
        where: u.username == ^email
      )

    #    and
    #    u.password_hash == ^pass_hash

    IO.inspect(Repo.one(query, prefix: prefix))

    # IO.inspect(Repo.get_by(User, username: email, prefix: prefix))
  end

  def change_user_password(email, password, prefix) do
    query =
      from(u in User,
        where: u.username == ^email
      )

    user = Repo.one(query, prefix: prefix)
    role_id = user.get_role_id
    usr = Map.new(password: password, role_id: role_id, username: email)
    update_user(user, usr, prefix)

    # IO.inspect(Repo.get_by(User, username: email, prefix: prefix))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    # passwd = Map.get(attrs, "password", nil)

    User.changeset(user, attrs)
    # |> check_password(passwd)
  end

  # defp check_password(user, password) do
  # Argon2.check_pass(password, user.password_hash)
  # end

  alias Inconn2Service.Staff.Role

  @doc """
  Returns the list of roles.

  ## Examples

      iex> list_roles()
      [%Role{}, ...]

  """
  def list_roles(prefix) do
    Repo.all(Role, prefix: prefix)
  end

  @doc """
  Gets a single role.

  Raises `Ecto.NoResultsError` if the Role does not exist.

  ## Examples

      iex> get_role!(123)
      %Role{}

      iex> get_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_role!(id, prefix), do: Repo.get!(Role, id, prefix: prefix)

  @doc """
  Creates a role.

  ## Examples

      iex> create_role(%{field: value})
      {:ok, %Role{}}

      iex> create_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_role(attrs \\ %{}, prefix) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a role.

  ## Examples

      iex> update_role(role, %{field: new_value})
      {:ok, %Role{}}

      iex> update_role(role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_role(%Role{} = role, attrs, prefix) do
    role
    |> Role.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a role.

  ## Examples

      iex> delete_role(role)
      {:ok, %Role{}}

      iex> delete_role(role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_role(%Role{} = role, prefix) do
    Repo.delete(role, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking role changes.

  ## Examples

      iex> change_role(role)
      %Ecto.Changeset{data: %Role{}}

  """
  def change_role(%Role{} = role, attrs \\ %{}) do
    Role.changeset(role, attrs)
  end
end
