defmodule Inconn2Service.ContractManagement do
  # import Ecto.Changeset
  # import Inconn2Service.Util.DeleteManager
  # import Ecto.Changeset
  import Inconn2Service.Util.IndexQueries
  import Inconn2Service.Util.HelpersFunctions
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo
  alias Inconn2Service.ContractManagement
  alias Inconn2Service.ContractManagement.Scope
  alias Inconn2Service.ContractManagement.Contract
  alias Inconn2Service.ContractManagement.ManpowerConfiguration
  alias Inconn2Service.AssetConfig.{Location, AssetCategory}
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Settings
  alias Inconn2Service.Staff
  alias Inconn2Service.ContractManagement.Sla
  alias Inconn2Service.ContractManagement.SlaEmailConfig

  def list_contracts(params, prefix) do
    Contract
    |> Repo.add_active_filter()
    |> contract_query(params)
    |> Repo.all(prefix: prefix)
    # |> Stream.map(fn c -> preload_scopes(c, prefix) end)
    |> Enum.map(fn c -> preload_service_provider(c, prefix) end)
  end

  def list_contracts(party_id, params, prefix) do
    from(c in Contract, where: c.party_id == ^party_id)
    |> Repo.add_active_filter()
    |> contract_query(params)
    |> Repo.all(prefix: prefix)
    # |> Enum.map(fn c -> preload_scopes(c, prefix) end)
    |> Enum.map(fn c -> preload_service_provider(c, prefix) end)
  end

  def get_contract!(id, prefix), do: Repo.get!(Contract, id, prefix: prefix)  |> preload_service_provider(prefix)

  def create_contract(attrs \\ %{}, prefix) do
    %Contract{}
    |> Contract.changeset(attrs)
    |> Repo.insert(prefix: prefix)
    # |> preload_scopes(prefix)
    |> preload_service_provider(prefix)
  end

  def update_contract(%Contract{} = contract, attrs, prefix) do
    contract
    |> Contract.changeset(attrs)
    |> Repo.update(prefix: prefix)
    # |> preload_scopes(prefix)
    |> preload_service_provider(prefix)
  end

  # def delete_contract(%Contract{} = contract, prefix) do
  #   Repo.delete(contract, prefix: prefix)
  # end

  # def delete_contract(%Contract{} = contract, prefix) do
  #   cond do
  #     has_scope?(contract, prefix) ->
  #       {:could_not_delete,
  #         "Cannot be deleted as there are Scopes associated with it"
  #       }
  #     has_manpower_configuration?(contract, prefix) ->
  #       {:could_not_delete,
  #         "Cannot be deleted as there are Manpower conigurations associated with it"
  #       }
  #     true ->
  #      update_contract(contract, %{"active" => false}, prefix)
  #        {:deleted,
  #           "The contract was disabled"
  #        }
  #   end
  # end

  def delete_contract(%Contract{} = contract, prefix) do
   deactive_scope_for_contract(contract.id, prefix)
   deactive_manpower_configuration_for_contract(contract.id, prefix)
   update_contract(contract, %{"active" => false}, prefix)
         {:deleted,
            "The contract was disabled"
         }
  end

  defp deactive_scope_for_contract(contract_id, prefix) do
    from(s in Scope, where: s.contract_id == ^contract_id)
    |> Repo.update_all([set: [active: false]], prefix: prefix)
  end

  defp deactive_manpower_configuration_for_contract(contract_id, prefix) do
    from(m in ManpowerConfiguration, where: m.contract_id == ^contract_id)
    |> Repo.update_all([set: [active: false]], prefix: prefix)
  end

  def change_contract(%Contract{} = contract, attrs \\ %{}) do
    Contract.changeset(contract, attrs)
  end

  def list_scopes(params, prefix) do
    Scope
    |> Repo.add_active_filter()
    |> scope_query(params)
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn s -> preload_site(s, prefix) end)
    |> Stream.map(fn s -> preload_locations(s, prefix) end)
    |> Stream.map(fn s -> preload_asset_categories(s, prefix) end)
  end

  def get_site_from_scopes(params, prefix) do
    list_scopes(params, prefix) |> Enum.map(fn x -> x.site end)
  end

  def list_scopes(contract_id, params, prefix) do
    from(s in Scope, where: s.contract_id == ^contract_id)
    |> Repo.add_active_filter()
    |> scope_query(params)
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn s -> preload_site(s, prefix) end)
    |> Stream.map(fn s -> preload_locations(s, prefix) end)
    |> Stream.map(fn s -> preload_asset_categories(s, prefix) end)
  end

  def list_scopes_by_contract_id(contract_id, prefix) do
    from(s in Scope, where: s.contract_id == ^contract_id)
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn s -> preload_site(s, prefix) end)
    |> Stream.map(fn s -> preload_locations(s, prefix) end)
    |> Stream.map(fn s -> preload_asset_categories(s, prefix) end)
  end

  def get_scope!(id, prefix), do: Repo.get!(Scope, id, prefix: prefix) |> preload_site(prefix) |> preload_asset_categories(prefix) |> preload_locations(prefix)

  def create_scope(attrs, query_params, prefix) do
    {:ok, scopes} = insert_scope(attrs, query_params["type"], prefix)
    {:ok, Enum.map(scopes, fn s -> preload_site(s, prefix) |> preload_asset_categories(prefix) |> preload_locations(prefix) end)}
  end

  def create_scope(attrs, prefix) do
    %Scope{}
    |> Scope.changeset(attrs)
    # |> validate_party_type(prefix)
    |> Repo.insert(prefix: prefix)
    |> preload_site(prefix)
    |> preload_asset_categories(prefix)
    |> preload_locations(prefix)
  end

  def update_scope(%Scope{} = scope, attrs, prefix) do
    scope
    |> Scope.changeset(attrs)
    # |> validate_party_type(prefix)
    |> Repo.update(prefix: prefix)
    |> preload_site(prefix)
    |> preload_asset_categories(prefix)
    |> preload_locations(prefix)
  end

  def delete_scope(%Scope{} = scope, prefix) do
    update_scope(scope, %{"active" => false}, prefix)
    {:deleted,
       "The Scope was disabled"
    }
  end

  def change_scope(%Scope{} = scope, attrs \\ %{}) do
    Scope.changeset(scope, attrs)
  end

  def list_manpower_configurations(prefix, query_params) do
    manpower_configuration_query(ManpowerConfiguration, query_params)
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> group_by_site_and_designation()
    |> List.flatten()
    |> Stream.map(&(form_config(&1, prefix)))
    |> Stream.map(fn mc -> preload_site(mc, prefix) end)
    |> Enum.map(fn mc -> preload_designation(mc, prefix) end)
  end

  def form_config(map, prefix) do
    config =
        Enum.map(map.grouped_by_designation_and_site, fn x ->
          %{
            shift_id: x.shift_id,
            quantity: x.quantity,
            id: x.id
          }
          |> preload_shift(prefix)
        end)
    %{
      site_id: map.site_id,
      designation_id: map.designation_id,
      config: config
    }
  end

  def group_by_site_and_designation(list) do
    Enum.group_by(list, &(&1.site_id))
    |> Enum.map(fn {site_id, v} -> group_by_designation_for_site(site_id, v) end)
  end

  def group_by_designation_for_site(site_id, list) do
    Enum.group_by(list, &(&1.designation_id))
    |> Enum.map(&(form_by_designation(site_id, &1)))
  end

  def form_by_designation(site_id, {k, v}) do
    %{
      designation_id: k,
      site_id: site_id,
      grouped_by_designation_and_site: v
    }
  end

  def get_manpower_configuration_with_preloads!(id, prefix) do
    get_manpower_configuration!(id, prefix)
    |> preload_site(prefix)
    |> preload_shift(prefix)
    |> preload_designation(prefix)
  end

  def get_manpower_configuration!(id, prefix), do: Repo.get!(ManpowerConfiguration, id, prefix: prefix)

  def create_multiple_manpower_configurations(attrs, prefix) do
    Enum.map(attrs["config"],
             &Task.async(fn ->
                            create_manpower_configuration(
                              Map.put(attrs, "shift_id", &1["shift_id"])
                              |> Map.put("quantity", &1["quantity"]),
                              prefix)
                          end))
    |> Task.await_many(:infinity)
  end

  def create_manpower_configuration(attrs \\ %{}, prefix) do
    %ManpowerConfiguration{}
    |> ManpowerConfiguration.changeset(attrs)
    |> Repo.insert(prefix: prefix)
    |> preload_site(prefix)
    |> preload_shift(prefix)
    |> preload_designation(prefix)
  end

  def create_or_update_manpower_configurations(action_func, attrs, prefix) do
    result = apply(ContractManagement, action_func, [attrs, prefix])

    failures = get_success_or_failure_list(result, :error)
    case length(failures) do
      0 ->
        {:ok, get_success_or_failure_list(result, :ok)}

      _ ->
        {:multiple_error, failures}
    end
  end

  def update_multiple_manpower_configurations(attrs, prefix) do
    attrs
    |> Enum.map(&Task.async(fn -> update_individual_manpower_configuration(&1, prefix) end))
    |> Task.await_many(:infinity)
  end

  def update_individual_manpower_configuration(attrs, prefix) do
    get_manpower_configuration!(attrs["id"], prefix)
    |> update_manpower_configuration(%{"quantity" => attrs["quantity"]}, prefix)
  end

  def update_manpower_configuration(%ManpowerConfiguration{} = manpower_configuration, attrs, prefix) do
    manpower_configuration
    |> ManpowerConfiguration.changeset(attrs)
    |> Repo.update(prefix: prefix)
    |> preload_site(prefix)
    |> preload_shift(prefix)
    |> preload_designation(prefix)
  end

  def delete_manpower_configuration(%ManpowerConfiguration{} = manpower_configuration, prefix) do
    # Repo.delete(manpower_configuration, prefix: prefix)
    update_manpower_configuration(manpower_configuration, %{"active" => false}, prefix)
    {:deleted, "Manpower configuration was deleted"}
  end

  def change_manpower_configuration(%ManpowerConfiguration{} = manpower_configuration, attrs \\ %{}) do
    ManpowerConfiguration.changeset(manpower_configuration, attrs)
  end

  defp preload_shift({:error, changeset}, _prefix), do: {:error, changeset}
  defp preload_shift({:ok, manpower_configuration}, prefix), do: {:ok, preload_shift(manpower_configuration, prefix)}
  defp preload_shift(manpower_configuration, prefix), do: Map.put(manpower_configuration, :shift, Settings.get_shift!(manpower_configuration.shift_id, prefix))

  defp preload_designation({:error, changeset}, _prefix), do: {:error, changeset}
  defp preload_designation({:ok, manpower_configuration}, prefix), do: {:ok, preload_designation(manpower_configuration, prefix)}
  defp preload_designation(manpower_configuration, prefix), do: Map.put(manpower_configuration, :designation, Staff.get_designation!(manpower_configuration.designation_id, prefix))

  defp insert_scope(attrs, "by_site", prefix) do
    attrs_for_sites = seperate_attrs_for_site(attrs["site_ids"], attrs)
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:scopes, fn _, _ -> insert_scopes_for_site(attrs_for_sites, prefix) end)
      |> Repo.transaction()

    case result do
      {:ok, %{scopes: scopes}} -> {:ok, scopes}
      _ -> {:could_not_create, "Failure"}
    end
  end

  defp insert_scopes_for_site(attrs, prefix) do
    result =
      Enum.map(attrs, fn a -> create_scope(a, prefix) end)
      |> Enum.filter(fn {a,_b} -> a == :ok end)

    case length(result) do
      0 -> {:error, "Failure"}
      _ -> {:ok, result |> Enum.map(fn {:ok, entry} -> entry end)}
    end
  end

  defp seperate_attrs_for_site(site_ids, attrs), do: Enum.map(site_ids, fn site_id -> Map.put(attrs, "site_id", site_id) |> Map.put("is_applicable_to_all_location", true) end)

  # defp preload_scopes({:error, changeset}, _prefix), do: {:error, changeset}
  # defp preload_scopes({:ok, contract}, prefix), do: {:ok, contract |> preload_scopes(prefix)}
  # defp preload_scopes(contract, prefix) do
  #   scopes = from(s in Scope, where: s.contract_id == ^contract.id and s.active) |> Repo.all(prefix: prefix)
  #   Map.put(contract, :scopes, scopes)
  # end

  defp preload_service_provider({:error, changeset}, _prefix), do: {:error, changeset}
  defp preload_service_provider({:ok, contract}, prefix), do: {:ok, preload_service_provider(contract, prefix)}
  defp preload_service_provider(contract, prefix), do: Map.put(contract, :service_provider, AssetConfig.get_party!(contract.party_id, prefix))

  defp preload_site({:error, changeset}, _prefix), do: {:error, changeset}
  defp preload_site({:ok, resource}, prefix), do: {:ok, preload_site(resource, prefix)}
  defp preload_site(resource, prefix), do: Map.put(resource, :site, AssetConfig.get_site!(resource.site_id, prefix))

  defp preload_locations({:error, changeset}, _prefix), do: {:error, changeset}
  defp preload_locations({:ok, scopes}, prefix), do: {:ok, preload_locations(scopes, prefix)}
  defp preload_locations(scopes, prefix), do: Map.put(scopes, :locations, get_resources_from_list(scopes.location_ids, Location, prefix))

  defp preload_asset_categories({:error, changeset}, _prefix), do: {:error, changeset}
  defp preload_asset_categories({:ok, scopes}, prefix), do: {:ok, preload_asset_categories(scopes, prefix)}
  defp preload_asset_categories(scopes, prefix), do: Map.put(scopes, :asset_categories, get_resources_from_list(scopes.asset_category_ids, AssetCategory, prefix))

  defp get_resources_from_list(nil, _query, _prefix), do: []

  defp get_resources_from_list(list, query, prefix) do
    from(q in query, where: q.id in ^list, select: %{id: q.id, name: q.name})
    |> Repo.all(prefix: prefix)
  end

  def create_sla(attrs \\ %{}, prefix) do
    %Sla{}
    |> Sla.changeset(attrs)
    |> Repo.insert(prefix: prefix)

    # |> preload_scopes(prefix)
  end

  def list_sla(params \\ %{}, prefix) do
    query_params = rectify_query_params(params)
    Sla
    |> sla_query(query_params)
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
    |> Stream.map(fn data -> put_approver_name(data, prefix) end)
  end

  defp rectify_query_params(query_params) do
    Enum.filter(query_params, fn {_key, value} ->
      value != "null"
      end) |> Enum.into(%{})
  end

  defp put_approver_name(reading, prefix) do
    user = Staff.get_user(reading.approver, prefix)
    Map.put(reading, :approver_name, user.email)
  end

  def update_sla(%Sla{} = sla, attrs, prefix) do
    sla
    |> Sla.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def get_sla!(id, prefix),
    do: Repo.get!(Sla, id, prefix: prefix)

  def create_sla_email_config(attrs \\ %{}, prefix) do
    %SlaEmailConfig{}
    |> SlaEmailConfig.changeset(attrs)
    |> Repo.insert(prefix: prefix)

    # |> preload_scopes(prefix)
  end

  def update_sla_email_config(%SlaEmailConfig{} = sla_email_config, attrs, prefix) do
    sla_email_config
    |> SlaEmailConfig.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def list_sla_email_config(prefix) do
    SlaEmailConfig
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end

  def get_sla_email_config!(id, prefix),
    do: Repo.get!(SlaEmailConfig, id, prefix: prefix)
end
