defmodule Inconn2Service.DataHandling.SeedData do
  alias Inconn2Service.DataHandling.SeedData
  alias Inconn2Service.Communication
  alias Inconn2Service.{Common, Staff, Account}

  @role_profiles [
    {"Admin", "ADMN"},
    {"Manager", "MNGR"},
    {"Supervisor", "SPVI"},
    {"Technician", "TECH"},
    {"Others", "OTHR"}
  ]

  #file read and insert data
  def read_and_insert(file_path, entity) do
    {:ok, content} = File.read(file_path)

    ["", content] =
        if String.starts_with?(content, "\uFEFF") do
          String.split(content, "\uFEFF")
        else
          ["", content]
        end

    content
    |> String.split(split_regex(content))
    |> Enum.filter(fn s -> s != "" end)
    |> Enum.map(fn s -> process_individual(entity, s) end)
  end

  #Seed features...
  def seed_features() do
    read_and_insert(Application.app_dir(:inconn2_service, "/priv/features/Features.csv"), :features)
    |> Enum.map(&(Common.create_feature(&1)))
  end

  #Seed role profiles...
  def seed_role_profiles(prefix) do
    @role_profiles
    |> Stream.map(&Task.async(fn ->
          {name, code} = &1
          Staff.create_role_profile(form_role_profile_map(name, code), prefix)
        end))
    |> Enum.map(&Task.await/1)
  end

   #seed public uom...
  def seed_public_uom() do
    read_and_insert(Application.app_dir(:inconn2_service, "/priv/features/Uom.csv"), :public_uom)
    |> Enum.map(&(Common.create_public_uom(&1)))
  end

  #seed message templates ...
  def seed_message_templates() do
    Application.app_dir(:inconn2_service, "priv/features/templates.json")
    |> File.read!()
    |> Jason.decode!()
    |> Enum.map(fn attrs ->
      Communication.create_message_templates(attrs)
    end)
  end

  #seed alert and notifications reserve ..
  def seed_alert_and_notifications_reserve() do
    Application.app_dir(:inconn2_service, "priv/features/alert.json")
    |> File.read!()
    |> Jason.decode!()
    |> Enum.map(fn attrs ->
      Common.create_alert_notification_reserve(attrs)
    end)
  end

  def update_hierarchy_id_in_role_profile(prefix) do
   map = role_profile_map()
   Staff.list_role_profiles(prefix)
   |> Enum.map(fn role_profile ->
       Staff.update_role_profile(role_profile, %{"hierarchy_id" => map[role_profile.name]}, prefix)
   end)
  end

  def update_hierarchy_id_in_role(prefix) do
    rp_map = get_role_profile_hierarchy_map(prefix)

    Staff.list_roles(prefix)
    |> Enum.map(fn role ->
        h_id = Map.fetch!(rp_map, role.role_profile_id)
        Staff.update_role(role, %{"hierarchy_id" => h_id}, prefix)
      end)
  end

  def get_role_profile_hierarchy_map(prefix) do
    Staff.list_role_profiles(prefix)
    |> Enum.map(fn rp -> {rp.id, rp.hierarchy_id} end)
    |> Enum.into(%{})
  end

  def update_prefixes() do
    Account.list_licensees()
    |> Enum.map(fn licensee -> "inc_" <> licensee.sub_domain end)
  end

  def update_hierarchy_id_in_role_all_tenants() do
    update_prefixes()
    |> Enum.map(&(update_hierarchy_id_in_role(&1)))
  end

  def update_hierarchy_id_in_role_profiles_for_all_tenants() do
    update_prefixes()
    |> Enum.map(&(update_hierarchy_id_in_role_profile(&1)))
  end

  def update_role_features_for_all_tenants() do
    prefixes =
      Account.list_licensees()
      |> Enum.map(fn licensee -> "inc_" <> licensee.sub_domain end)

      Enum.map(prefixes, &(update_existing_role_profiles(&1)))
      Enum.map(prefixes, &(update_existing_roles(&1)))
  end

  def update_existing_role_profiles(prefix) do
    @role_profiles
    |> Enum.map(fn {name, code} ->
        case Staff.get_role_profile_by_name(name, prefix) do
          nil -> nil
          rp -> Staff.update_role_profile(rp, form_role_profile_map(name, code), prefix)
        end
    end)
  end

  def update_existing_roles(prefix) do
    Staff.list_roles(prefix)
    |> Enum.map(fn role ->
         update_role_permissions(role.role_profile_id, role, prefix)
       end)
  end

  #common function to seed all
  def seed_data() do
    SeedData.seed_features()
    SeedData.seed_message_templates()
    SeedData.seed_public_uom()
    SeedData.seed_alert_and_notifications_reserve()
  end

  defp update_role_permissions(role_profile_id, role, prefix) do
    rp = Staff.get_role_profile!(role_profile_id, prefix) |> Staff.filter_permissions()
    Staff.update_role(role, %{"permissions" => rp.permissions}, prefix)
  end

  #form an role profile map
  defp form_role_profile_map(name, code) do
    %{
      "name" => name,
      "code" => code,
      "hierarchy_id" => role_profile_map()[name],
      "permissions" => read_and_insert(Application.app_dir(:inconn2_service, "/priv/features/#{name}.csv"), :role_profile)
    }
  end

  #role profile map
  defp role_profile_map() do
    %{
      "SuperAdmin" => 0,
      "Admin" => 1,
      "Manager" => 2,
      "Supervisor" => 3,
      "Technician" => 4,
      "Others" => 5
    }
  end

  defp split_regex(content) do
    cond do
      String.contains?(content, "\r\n") -> "\r\n"
      true -> "\n"
    end
  end

  #process individual data  in the features file and make a map %{"name" => name, "code" => code} like this
  defp process_individual(:features, string) do
    {name, code} =
      string
      |> String.split(",")
      |> List.to_tuple()

    %{"name" => name, "code" => code}

  end

  #process individual data  in the role_profile file and make a map  %{"feature_code" => code, "feature_name" => name, "access" => access=="Y"} like this
  defp process_individual(:role_profile, string) do
    {name, code, access} =
      string
      |> String.split(",")
      |> List.to_tuple()

    %{"feature_code" => code, "feature_name" => name, "access" => access=="Y"}

  end

  #process individual data  in the public_uom file and make a map %{"uom_category" => uom_category, "uom_unit" => uom_unit, "description" => description} like this
  defp process_individual(:public_uom, string) do
    {uom_category, uom_unit, description} =
      string
      |> String.split(",")
      |> List.to_tuple()

    %{"uom_category" => uom_category, "uom_unit" => uom_unit, "description" => description}

  end
end
