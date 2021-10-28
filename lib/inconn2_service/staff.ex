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
  alias Inconn2Service.AssetConfig.AssetCategory

  @doc """
  Returns the list of employees.

  ## Examples

      iex> list_employees()
      [%Employee{}, ...]

  """
  def list_employees(party_id, prefix) do
    Employee
    |> where(party_id: ^party_id)
    |> Repo.all(prefix: prefix)
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

    Repo.one(query, prefix: prefix)
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
        |> validate_skill_ids(prefix)
        |> validate_role_ids(prefix)
        |> Repo.insert(prefix: prefix)

       case employee_set do
         {:ok, emp_set} ->
                 case create_user(attrs, prefix) do
                   {:ok, _user} ->
                       employee_set

                   {:error, _changeset} ->
                       Repo.delete(emp_set, prefix: prefix)
                 end

         {:error, _change_set} ->
                 employee_set
       end

    else
         %Employee{}
         |> Employee.changeset(attrs)
         |> validate_skill_ids(prefix)
         |> Repo.insert(prefix: prefix)
    end
  end

  defp validate_skill_ids(cs, prefix) do
    ids = get_change(cs, :skills, nil)
    if ids != nil do
      asset_categories = from(a in AssetCategory, where: a.id in ^ids )
              |> Repo.all(prefix: prefix)
      case length(ids) == length(asset_categories) do
        true -> cs
        false -> add_error(cs, :skills, "Skills are invalid")
      end
    else
      cs
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
    |> validate_skill_ids(prefix)
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
    user = get_user_by_username(employee.email, prefix)
    Repo.delete(user, prefix: prefix)
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
  alias Inconn2Service.Staff.Role
  alias Inconn2Service.Account.Auth

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

  def get_user_by_username(username, prefix) do
    query =
      from(u in User,
      where: u.username == ^username
      )

      Repo.one(query, prefix: prefix)
    end
  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}, prefix) do
      user_map = %{
        "username" => attrs["email"],
        "password" => attrs["mobile_no"],
        "password_confirmation" => attrs["mobile_no"],
        "party_id" => attrs["party_id"],
        "role_ids" => attrs["role_ids"]
      }

      %User{}
      |> User.changeset(user_map)
      |> Repo.insert(prefix: prefix)
  end

  defp validate_role_ids(cs, prefix) do
    role_ids = get_field(cs, :role_ids, nil)
    if role_ids != nil do
      roles = from(r in Role, where: r.id in ^role_ids )
                  |> Repo.all(prefix: prefix)
      case length(role_ids) == length(roles) do
        false -> add_error(cs, :role_ids, "role ids are not valid")
        true -> cs
      end
    else
      cs
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
    |> validate_role_ids(prefix)
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


  def change_user_password(user, credentials, prefix) do
    old_password = credentials["old_password"]
    attrs = %{
      "password" => credentials["new_password"],
      "password_confirmation" => credentials["new_password_confirmation"]
    }
    case Auth.check_password(old_password, user) do
      {:ok, user} ->
              update_user(user, attrs, prefix)
      {:error, msg} ->
              {:error, msg}
    end

  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  # defp check_password(user, password) do
  # Argon2.check_pass(password, user.password_hash)
  # end


  alias Inconn2Service.Staff.Feature

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
  def get_role(id, prefix), do: Repo.get(Role, id, prefix: prefix)

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
    |> validate_features(prefix)
    |> Repo.insert(prefix: prefix)
  end

  defp validate_features(cs, prefix) do
    features = get_field(cs, :features, nil)
    if features != nil do
      codes = Feature |> select([f], f.code) |> Repo.all(prefix: prefix)
      features = MapSet.new(features)
      codes = MapSet.new(codes)
      case MapSet.subset?(features, codes) do
        true -> cs
        false -> add_error(cs, :features, "feature codes are not valid")
      end
    else
      cs
    end
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
    |> validate_features(prefix)
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



  @doc """
  Returns the list of features.

  ## Examples

      iex> list_features()
      [%Feature{}, ...]

  """
  def list_features(prefix) do
    Repo.all(Feature, prefix: prefix)
  end

  def search_features(name_text, prefix) do
    if String.length(name_text) < 3 do
      []
    else
      search_text = name_text <> "%"

      from(f in Feature, where: ilike(f.name, ^search_text), order_by: f.name)
      |> Repo.all(prefix: prefix)
    end
  end
  @doc """
  Gets a single feature.

  Raises `Ecto.NoResultsError` if the Feature does not exist.

  ## Examples

      iex> get_feature!(123)
      %Feature{}

      iex> get_feature!(456)
      ** (Ecto.NoResultsError)

  """
  def get_feature!(id, prefix), do: Repo.get!(Feature, id, prefix: prefix)

  @doc """
  Creates a feature.

  ## Examples

      iex> create_feature(%{field: value})
      {:ok, %Feature{}}

      iex> create_feature(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feature(attrs \\ %{}, prefix) do
    %Feature{}
    |> Feature.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a feature.

  ## Examples

      iex> update_feature(feature, %{field: new_value})
      {:ok, %Feature{}}

      iex> update_feature(feature, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_feature(%Feature{} = feature, attrs, prefix) do
    feature
    |> Feature.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a feature.

  ## Examples

      iex> delete_feature(feature)
      {:ok, %Feature{}}

      iex> delete_feature(feature)
      {:error, %Ecto.Changeset{}}

  """
  def delete_feature(%Feature{} = feature, prefix) do
    Repo.delete(feature, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feature changes.

  ## Examples

      iex> change_feature(feature)
      %Ecto.Changeset{data: %Feature{}}

  """
  def change_feature(%Feature{} = feature, attrs \\ %{}) do
    Feature.changeset(feature, attrs)
  end
end
