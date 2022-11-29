defmodule Inconn2Service.SeedFeatures do
  alias Inconn2Service.{Common, Staff, Account}

  @role_profiles [
    {"Admin", "ADMN"},
    {"Manager", "MNGR"},
    {"Supervisor", "SPVI"},
    {"Technician", "TECH"},
    {"Others", "OTHR"}
  ]

  def read_and_insert(file_path, entity) do
    {:ok, "\uFEFF" <> content} = File.read(file_path)

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

  defp split_regex(content) do
    cond do
      String.contains?(content, "\r\n") -> "\r\n"
      true -> "\n"
    end
  end

  defp process_individual(:features, string) do
    {name, code} =
      string
      |> String.split(",")
      |> List.to_tuple()

    %{"name" => name, "code" => code}

  end

  defp process_individual(:role_profile, string) do
    {name, code, access} =
      string
      |> String.split(",")
      |> List.to_tuple()

    %{"feature_code" => code, "feature_name" => name, "access" => access=="Y"}

  end

  #Seed features...
  def seed_features() do
    read_and_insert(Application.app_dir(:inconn2_service, "/priv/features/Features.csv"), :features)
    |> Enum.map(&(Common.create_feature(&1)))
    # |> Stream.map(&Task.async(fn -> Common.create_feature(&1) end))
    # |> Enum.map(&Task.await/1)
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

  def update_role_features_for_all_tenants() do
    prefixes =
      Account.list_licensees()
      |> Enum.map(fn licensee -> "inc_" <> licensee.sub_domain end)

      Enum.map(prefixes, &(update_existing_role_profiles(&1)))
      Enum.map(prefixes, &(update_existing_roles(&1)))

    # prefixes
    # |> Enum.map(&Task.async(fn -> update_existing_role_profiles(&1) end))
    # |> Enum.map(&Task.await/1)

    # prefixes
    # |> Enum.map(&Task.async(fn -> update_existing_roles(&1) end))
    # |> Enum.map(&Task.await/1)
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

  defp update_role_permissions(role_profile_id, role, prefix) do
    rp = Staff.get_role_profile!(role_profile_id, prefix) |> Staff.filter_permissions()
    Staff.update_role(role, %{"permissions" => rp.permissions}, prefix)
  end

  defp form_role_profile_map(name, code) do
    %{
      "name" => name,
      "code" => code,
      "permissions" => read_and_insert(Application.app_dir(:inconn2_service, "/priv/features/#{name}.csv"), :role_profile)
    }
  end

end
