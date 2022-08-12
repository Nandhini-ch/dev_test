defmodule Inconn2Service.Staff do
  import Ecto.Query, warn: false
  import Ecto.Changeset
  import Comeonin
  import Inconn2Service.Util.DeleteManager
  # import Inconn2Service.Util.IndexQueries
  # import Inconn2Service.Util.HelpersFunctions

  alias Ecto.Multi
  alias Inconn2Service.Repo
  alias Inconn2Service.Account.Auth
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.AssetCategory
  alias Inconn2Service.Staff.{Employee, Feature, Module, OrgUnit, Role, RoleProfile,User}
  alias Inconn2Service.Util.HierarchyManager

  def list_org_units(prefix) do
    OrgUnit
    |> Repo.all(prefix: prefix)
  end

  def list_org_units(party_id, prefix) do
    OrgUnit
    |> Repo.add_active_filter()
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

  def delete_org_unit(%OrgUnit{} = org_unit, prefix) do
    cond do
      has_descendants?(org_unit, prefix) ->
        {:could_not_delete,
           "Cannot be deleted as there are Descendants associated with it"
        }

      has_employee?(org_unit, prefix) ->
        {:could_not_delete,
           "cannot be deleted as there are Employee associated with it"
        }

      true ->
        update_org_unit(org_unit, %{"active" => false}, prefix)
          {:deleted,
             "The org unit was disabled"
         }
    end
  end

  def change_org_unit(%OrgUnit{} = org_unit, attrs \\ %{}) do
    OrgUnit.changeset(org_unit, attrs)
  end

  #Context functions for Employees
  def list_employees(prefix) do
    Employee
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
  end

  def list_employees(user, prefix) do
    filters = filter_by_user_is_licensee(user, prefix)
    Employee
    |> where(^filters)
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn employee -> preload_employee(employee, prefix) end)
    |> Enum.map(fn employee -> preload_skills(employee, prefix) end)
    |> Repo.preload(:org_unit)
  end

  defp filter_by_user_is_licensee(user, prefix) do
    case (AssetConfig.get_party!(user.party_id, prefix)).licensee do
      false -> [party_id: user.party_id]
      true -> []
    end
  end

  defp preload_employee({:ok, employee}, prefix) do
    {:ok, employee |> preload_employee(prefix)}
  end

  defp preload_employee(employee, _prefix) when is_nil(employee.reports_to), do: Map.put(employee, :reports_to_employee, nil)

  defp preload_employee(employee, prefix) when not is_nil(employee.reports_to) do
    reports_to_employee = Repo.get!(Employee, employee.reports_to, prefix: prefix)
    Map.put(employee, :reports_to_employee, reports_to_employee)
  end

  defp preload_skills({:ok, employee}, prefix) do
    {:ok, employee |> preload_skills(prefix)}
  end

  defp preload_skills(employee, prefix) when not is_nil(employee.skills) do
    asset_categories = Enum.map(employee.skills, fn s -> AssetConfig.get_asset_category(s, prefix) end) |> Enum.filter(fn x -> not is_nil(x) end)
    Map.put(employee, :preloaded_skills, asset_categories)
  end

  defp preload_skills(employee, _prefix) when is_nil(employee.skills) do
    Map.put(employee, :preloaded_skills, [])
  end

  def get_employee_of_user(user, prefix) do
    Repo.get(Employee, user.id, prefix: prefix)
  end

  def get_reportees_for_logged_in_user(user, prefix) do
    employee = user.employee
    if employee != nil do
      Employee
      |> where(reports_to: ^employee.id)
      |> Repo.all(prefix: prefix)
      |> Enum.map(fn employee -> preload_employee(employee, prefix) end)
      |> Enum.map(fn employee -> preload_skills(employee, prefix) end)
      |> Repo.preload(:org_unit)
    else
      []
    end
  end

  def get_reportees_for_employee(employee_id, prefix) do
    Employee
    |> where(reports_to: ^employee_id)
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn employee -> preload_employee(employee, prefix) end)
    |> Enum.map(fn employee -> preload_skills(employee, prefix) end)
    |> Repo.preload(:org_unit)
  end

  def get_employee!(id, prefix) do
    Repo.get!(Employee, id, prefix: prefix)
    |> preload_employee(prefix)
    |> preload_skills(prefix)
    |> Repo.preload(:org_unit)
    |> Repo.preload(:user)
  end

  def get_employee_email!(email, prefix) do
    query =
      from(e in Employee,
        where: e.email == ^email
      )

    Repo.one(query, prefix: prefix)
    |> Repo.preload(:org_unit)
  end

  def create_employee(attrs \\ %{}, prefix) do
    has_login_credentials = Map.get(attrs, "has_login_credentials", false)

    if has_login_credentials == true do
      employee_set =
        %Employee{}
        |> Employee.changeset(attrs)
        |> validate_skill_ids(prefix)
        |> validate_role_id(prefix)
        |> Repo.insert(prefix: prefix)

       case employee_set do
         {:ok, emp_set} ->
                 case create_employee_user(emp_set, attrs, prefix) do
                   {:ok, _user} ->
                       {:ok, emp_set |> preload_employee(prefix) |> preload_skills(prefix) |> Repo.preload(:org_unit)}

                   {:error, changeset} ->
                       Repo.delete(emp_set, prefix: prefix)
                       {:error, changeset}
                 end

         {:error, _change_set} ->
                 employee_set
       end

    else
      employee_set = %Employee{}
                      |> Employee.changeset(attrs)
                      |> validate_skill_ids(prefix)
                      |> Repo.insert(prefix: prefix)
      case employee_set do
        {:ok, emp_set} -> {:ok, emp_set |> preload_employee(prefix) |> preload_skills(prefix) |> Repo.preload(:org_unit)}
        _ -> employee_set
      end
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

  def update_employee(%Employee{} = employee, attrs, prefix) do
    has_login_credentials = Map.get(attrs, "has_login_credentials", false)

    if has_login_credentials == true do
      employee_set = employee
                      |> Employee.changeset(attrs)
                      |> validate_skill_ids(prefix)
                      |> validate_role_id(prefix)
                      |> Repo.update(prefix: prefix)
        case employee_set do
          {:ok, emp_set} ->
                  create_employee_user(emp_set, attrs, prefix)
                  {:ok, emp_set |> preload_employee(prefix) |> preload_skills(prefix) |> Repo.preload(:org_unit)}
          _ ->
                  employee_set
        end

    else
      employee_set = employee
                    |> Employee.changeset(attrs)
                    |> validate_skill_ids(prefix)
                    |> Repo.update(prefix: prefix)
      case employee_set do
          {:ok, emp_set} ->
                  {:ok, emp_set |> preload_employee(prefix) |> preload_skills(prefix) |> Repo.preload(:org_unit)}
          _ ->
                  employee_set
      end
    end
  end

  def delete_employee(%Employee{} = employee, prefix) do
    cond  do
      has_employee_rosters?(employee, prefix) ->
        {:could_not_delete,
           "cannot be deleted as there are Employee Roster associated with it"
        }

      has_reports_to?(employee, prefix) ->
        {:could_not_delete,
           "cannot be deleted as there are Reports To associated with it"
        }

      true ->
        case delete_user_for_employee(employee.user, prefix) do
          {:deleted, _} ->
              update_employee(employee, %{"active" => false}, prefix)
              {:deleted, "The employee was disabled"}

          user_delete_result ->
            user_delete_result

        end
    end
  end

  def change_employee(%Employee{} = employee, attrs \\ %{}) do
    Employee.changeset(employee, attrs)
  end

#Context functions for User
  def list_users(prefix) do
    Repo.all(User, prefix: prefix)
    |> Repo.add_active_filter()
    |> Repo.preload(employee: :org_unit)
  end

  def list_users(user, prefix) do
    filters = filter_by_user_is_licensee(user, prefix)
    User
    |> where(^filters)
    |> Repo.all(prefix: prefix)
    |> Repo.preload(employee: :org_unit)
  end


  def get_user!(id, prefix), do: Repo.get!(User, id, prefix: prefix) |> Repo.preload(employee: :org_unit)
  def get_user(id, prefix), do: Repo.get(User, id, prefix: prefix) |> Repo.preload(employee: :org_unit)
  def get_user_without_org_unit!(id, prefix), do: Repo.get(User, id, prefix: prefix) |> Repo.preload(:employee)

  def get_user_without_org_unit(nil,_prefix), do: nil

  def get_user_without_org_unit(id,prefix) do
    user = Repo.get(User, id, prefix: prefix)
    case user do
      nil -> nil
      _ -> user |> Repo.preload(:employee)
    end
  end

  def get_user_by_username_for_otp(username, prefix) do
    user = get_user_by_username(username, prefix)
    IO.inspect("1323424")
    IO.inspect(user)
    case user do
      nil ->  {:error, "Username not found"}
      _ -> {:ok, user}
    end
  end

  def get_user_by_username(username, prefix) do
    query =
      from(u in User,
      where: u.username == ^username
      )

      Repo.one(query, prefix: prefix)
      |> Repo.preload(employee: :org_unit)
  end

  def get_user_by_username(username, user, prefix) do
    query =
      from(u in User,
      where: u.username == ^username and u.party_id == ^user.party_id
      )

      Repo.one(query, prefix: prefix)
      |> Repo.preload(employee: :org_unit)
    end

  def create_user(attrs \\ %{}, prefix) do
    result = %User{}
              |> User.changeset(attrs)
              |> validate_role_id(prefix)
              |> Repo.insert(prefix: prefix)
    case result do
      {:ok, user} -> {:ok, user |> Repo.preload(employee: :org_unit)}
      _ -> result
    end
  end

  def create_employee_user(employee, attrs \\ %{}, prefix) do
      user_map = %{
        "username" => employee.email,
        "first_name" => employee.first_name,
        "last_name" => employee.last_name,
        "email" => employee.email,
        "mobile_no" => employee.mobile_no,
        "password" => employee.mobile_no,
        "password_confirmation" => employee.mobile_no,
        "party_id" => employee.party_id,
        "employee_id" => employee.id,
        "role_id" => attrs["role_id"]
      }

      %User{}
      |> User.changeset(user_map)
      |> Repo.insert(prefix: prefix)
  end

  def create_licensee_admin(attrs \\ %{}, prefix) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  defp validate_role_id(cs, prefix) do
    role_id = get_field(cs, :role_id, nil)
    if role_id != nil do
      case get_role(role_id, prefix) do
        nil -> add_error(cs, :role_id, "role id is not valid")
        _ -> cs
      end
    else
      cs
    end
  end

  def update_user(%User{} = user, attrs, prefix) do
    result = user
              |> User.changeset_update(attrs)
              |> validate_role_id(prefix)
              |> Repo.update(prefix: prefix)
    case result do
      {:ok, user} -> {:ok, user |> Repo.preload([employee: :org_unit], force: true)}
      _ -> result
    end
  end

  def delete_user(%User{} = user, prefix) do
    cond do
      has_alert_configuration?(user, prefix) ->
        {:could_not_delete,
          "Cannot be deleted as there are Alert Configuration associated with it"
        }

      has_employee?(user, prefix) ->
        {:could_not_delete,
           "Cannot be deleted as there are Employee associated with it"
        }

      has_category_helpdesk?(user, prefix) ->
        {:could_not_delete,
           "Cannot be deleted as there are Category Helpdesk associated with it"
        }

      has_store?(user, prefix) ->
       {:could_not_delete,
         "Cannot be deleted as there are Store associated with it"
       }

      true ->
       update_user(user, %{"active" => false}, prefix)
       {:deleted,
         "The user was disabled"
       }
    end
  end

  def delete_user_for_employee(nil , _prefix), do: {:deleted, nil}
  def delete_user_for_employee(%User{} = user, prefix) do
    cond do
      has_alert_configuration?(user, prefix) ->
        {:could_not_delete,
          "Cannot be deleted as there are Alert Configuration associated with it"
        }

      has_category_helpdesk?(user, prefix) ->
        {:could_not_delete,
           "Cannot be deleted as there are Category Helpdesk associated with it"
        }

      has_store?(user, prefix) ->
       {:could_not_delete,
         "Cannot be deleted as there are Store associated with it"
       }

      true ->
       update_user(user, %{"active" => false}, prefix)
       {:deleted,
         "The user was disabled"
       }
    end
  end


  def change_user_password(user, credentials, prefix) do
    case Auth.check_password(credentials["old_password"], user) do
      {:ok, user} ->
              User.change_password_changeset(user, %{"password" => credentials["new_password"]}) |> Repo.update(prefix: prefix)
      {:error, msg} ->
              {:error, msg}
    end
  end

  def reset_user_password(user, credentials, prefix) do
    User.change_password_changeset(user, %{"password" => credentials["password"]}) |> Repo.update(prefix: prefix)
  end


  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  #Context function for Role
  def list_roles(prefix) do
    Role
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Repo.preload(:role_profile)
  end

  def get_role!(id, prefix), do: Repo.get!(Role, id, prefix: prefix) |> Repo.preload(:role_profile)
  def get_role(id, prefix), do: Repo.get(Role, id, prefix: prefix) |> Repo.preload(:role_profile)
  def get_role_without_preload(id, prefix), do: Repo.get(Role, id, prefix: prefix)
  def get_role_by_role_profile(role_profile_id, prefix) do
    Role
    |> where(role_profile_id: ^role_profile_id)
    |> Repo.all(prefix: prefix)
    |> Repo.preload(:role_profile)
  end

  def create_role(attrs \\ %{}, prefix) do
    result = %Role{}
              |> Role.changeset(attrs)
              |> Repo.insert(prefix: prefix)
    case result do
      {:ok, role} -> {:ok, role |> Repo.preload(:role_profile)}
      _ -> result

    end
  end

  def update_role(%Role{} = role, attrs, prefix) do
    role
    |> Role.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_role(%Role{} = role, prefix) do
    cond do
      has_user?(role, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as there are User associated with it"
        }

      true ->
         update_role(role, %{"active" => false}, prefix)
          {:deleted,
             "The Role was disabled"
          }
    end
  end



  def change_role(%Role{} = role, attrs \\ %{}) do
    Role.changeset(role, attrs)
  end

  defp handle_hierarchical_activation(resource, resource_params, module, prefix, parent_id) do
    resource
    |> module.changeset(resource_params)
    |> validate_parent_for_true_condition(module, prefix, parent_id)
    |> Repo.update(prefix: prefix)
    |> update_children(prefix)
  end

  defp deactivate_children(resource, resource_params, module, prefix) do
    descendants = HierarchyManager.descendants(resource)
    Repo.update_all(descendants, [set: [active: false]], prefix: prefix)
    resource |> module.changeset(resource_params) |> Repo.update(prefix: prefix)
  end

  defp validate_parent_for_true_condition(cs, module, prefix, parent_id) do
    # parent_id = get_field(cs, :parent_id, nil)
    IO.inspect("Parent Id is #{parent_id}")
    if parent_id != nil do
      parent = Repo.get(module, parent_id, prefix: prefix)
      if parent != nil do
        case parent.active do
          false -> add_error(cs, :parent_id, "Parent Not Active")
          _ -> cs
        end
      else
        add_error(cs, :parent_id, "Parent Not Found")
      end
    else
      cs
    end
  end

  defp update_children({:ok, resource}, prefix) do
    descendants = HierarchyManager.descendants(resource)
    Repo.update_all(descendants, [set: [active: true]], prefix: prefix)
    {:ok, resource}
  end

  defp update_children({:error, cs}, _prefix), do: {:error, cs}

  def list_features(prefix) do
    Repo.all(Feature, prefix: prefix)
  end

  def list_features(module_id, prefix) do
    Feature
    |> where(module_id: ^module_id)
    |> Repo.all(prefix: prefix)
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

  def get_feature!(id, prefix), do: Repo.get!(Feature, id, prefix: prefix)

  def create_feature(attrs \\ %{}, prefix) do
    %Feature{}
    |> Feature.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_feature(%Feature{} = feature, attrs, prefix) do
    feature
    |> Feature.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_feature(%Feature{} = feature, prefix) do
    Repo.delete(feature, prefix: prefix)
  end

  def change_feature(%Feature{} = feature, attrs \\ %{}) do
    Feature.changeset(feature, attrs)
  end

  #Context functions for module
  def list_modules(prefix) do
    Repo.all(Module, prefix: prefix) |> Repo.preload(:features)
  end

  def get_module!(id, prefix), do: Repo.get!(Module, id, prefix: prefix) |> Repo.preload(:features)

  def create_module(attrs \\ %{}, prefix) do
    %Module{}
    |> Module.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_module(%Module{} = module, attrs, prefix) do
    module
    |> Module.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_module(%Module{} = module, prefix) do
    Repo.delete(module, prefix: prefix)
  end

  def change_module(%Module{} = module, attrs \\ %{}) do
    Module.changeset(module, attrs)
  end

  #Context functions for role profile
  def list_role_profiles(prefix) do
    Repo.all(RoleProfile, prefix: prefix)
  end

  def get_role_profile!(id, prefix), do: Repo.get!(RoleProfile, id, prefix: prefix)
  def get_role_profile(id, prefix), do: Repo.get(RoleProfile, id, prefix: prefix)
  def get_role_profile_by_name!(name, prefix), do: Repo.get_by!(RoleProfile, [name: name], prefix: prefix)

  def create_role_profile(attrs \\ %{}, prefix) do
    %RoleProfile{}
    |> RoleProfile.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def filter_permissions(role_profile) do
    permissions = Enum.map(role_profile.permissions, fn module -> filter_features(module) end)
    Map.put(role_profile, :permissions, permissions)
  end

  defp filter_features(module) do
    features = Enum.filter(module["features"], fn feature -> feature["access"] == true end)
    Map.put(module, "features", features)
  end

  # defp inherit_features(role_profile, role_profile_new, prefix) do
  #   feature_ids = role_profile.feature_ids
  #   new_feature_ids = role_profile_new.feature_ids
  #   check_for_addition(role_profile.id, feature_ids, new_feature_ids, prefix)
  #   check_for_removal(role_profile.id, feature_ids, new_feature_ids, prefix)
  # end

  # defp check_for_addition(role_profile_id, feature_ids, new_feature_ids, prefix) do
  #   added_ids = new_feature_ids -- feature_ids
  #   if length(added_ids) > 0 do
  #     roles = get_role_by_role_profile(role_profile_id, prefix)
  #     Enum.map(roles, fn role ->
  #                         feature_ids = role.feature_ids ++ added_ids
  #                         update_role(role, %{"feature_ids" => feature_ids}, prefix)
  #                       end)
  #     new_feature_ids
  #   else
  #     new_feature_ids
  #   end
  # end

  # defp check_for_removal(role_profile_id, feature_ids, new_feature_ids, prefix) do
  #   removed_ids = feature_ids -- new_feature_ids
  #   if length(removed_ids) > 0 do
  #     roles = get_role_by_role_profile(role_profile_id, prefix)
  #     Enum.map(roles, fn role ->
  #                         feature_ids = role.feature_ids -- removed_ids
  #                         update_role(role, %{"feature_ids" => feature_ids}, prefix)
  #                       end)
  #     new_feature_ids
  #   else
  #     new_feature_ids
  #   end
  # end

  @doc """
  Updates a role_profile.

  ## Examples

      iex> update_role_profile(role_profile, %{field: new_value})
      {:ok, %RoleProfile{}}

      iex> update_role_profile(role_profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_role_profile(%RoleProfile{} = role_profile, attrs, prefix) do
    result = role_profile
            |> RoleProfile.changeset(attrs)
            |> Repo.update(prefix: prefix)
    case result do
      {:ok, _role_profile_new} ->
              #inherit_features(role_profile, role_profile_new, prefix)
              result
       _ ->
              result
    end
  end

  def delete_role_profile(%RoleProfile{} = role_profile, prefix) do
    Repo.delete(role_profile, prefix: prefix)
  end

  def change_role_profile(%RoleProfile{} = role_profile, attrs \\ %{}) do
    RoleProfile.changeset(role_profile, attrs)
  end
end
