defmodule Inconn2Service.ContractManagement do
  # import Ecto.Changeset
  import Inconn2Service.Util.DeleteManager
  # import Ecto.Changeset
  import Inconn2Service.Util.IndexQueries
  # import Inconn2Service.Util.HelpersFunctions
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo
  alias Inconn2Service.ContractManagement.Scope
  alias Inconn2Service.ContractManagement.Contract
  alias Inconn2Service.AssetConfig.Location
  alias Inconn2Service.AssetConfig

  def list_contracts(params, prefix) do
    Contract
    |> Repo.add_active_filter()
    |> contract_query(params)
    |> Repo.all(prefix: prefix)
    |> Stream.map(fn c -> preload_scopes(c, prefix) end)
    |> Enum.map(fn c -> preload_service_provider(c, prefix) end)
  end

  def list_contracts(party_id, params, prefix) do
    from(c in Contract, where: c.party_id == ^party_id)
    |> Repo.add_active_filter()
    |> contract_query(params)
    |> Repo.all(prefix: prefix)
    |> Enum.map(fn c -> preload_scopes(c, prefix) end)
    |> Enum.map(fn c -> preload_service_provider(c, prefix) end)
  end

  def get_contract!(id, prefix), do: Repo.get!(Contract, id, prefix: prefix) |> preload_scopes(prefix) |> preload_service_provider(prefix)


  def create_contract(attrs \\ %{}, prefix) do
    %Contract{}
    |> Contract.changeset(attrs)
    |> Repo.insert(prefix: prefix)
    |> preload_scopes(prefix)
    |> preload_service_provider(prefix)
  end

  def update_contract(%Contract{} = contract, attrs, prefix) do
    contract
    |> Contract.changeset(attrs)
    |> Repo.update(prefix: prefix)
    |> preload_scopes(prefix)
    |> preload_service_provider(prefix)
  end

  # def delete_contract(%Contract{} = contract, prefix) do
  #   Repo.delete(contract, prefix: prefix)
  # end

  def delete_contract(%Contract{} = contract, prefix) do
    cond do
      has_scope?(contract, prefix) ->
        {:could_not_delete,
          "Cannot be deleted as there are Scopes associated with it"
        }

      true ->
       update_contract(contract, %{"active" => false}, prefix)
         {:deleted,
            "The contract was disabled"
         }
    end
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

  def list_scopes(contract_id, params, prefix) do
    from(s in Scope, where: s.contract_id == ^contract_id)
    |> Repo.add_active_filter()
    |> scope_query(params)
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

  defp preload_scopes({:error, changeset}, _prefix), do: {:error, changeset}
  defp preload_scopes({:ok, contract}, prefix), do: {:ok, contract |> preload_scopes(prefix)}
  defp preload_scopes(contract, prefix) do
    scopes = from(s in Scope, where: s.contract_id == ^contract.id and s.active) |> Repo.all(prefix: prefix)
    Map.put(contract, :scopes, scopes)
  end

  defp preload_service_provider({:error, changeset}, _prefix), do: {:error, changeset}
  defp preload_service_provider({:ok, contract}, prefix), do: {:ok, preload_service_provider(contract, prefix)}
  defp preload_service_provider(contract, prefix), do: Map.put(contract, :service_provider, AssetConfig.get_party!(contract.party_id, prefix))

  def preload_site({:error, changeset}, _prefix), do: {:error, changeset}
  def preload_site({:ok, scope}, prefix), do: {:ok, preload_site(scope, prefix)}
  def preload_site(scope, prefix), do: Map.put(scope, :site, AssetConfig.get_site!(scope.site_id, prefix))

  def preload_locations({:error, changeset}, _prefix), do: {:error, changeset}
  def preload_locations({:ok, scopes}, prefix), do: {:ok, preload_locations(scopes, prefix)}
  def preload_locations(scopes, prefix), do: Map.put(scopes, :locations, get_resources_from_list(scopes.location_ids, Location, prefix))

  def preload_asset_categories({:error, changeset}, _prefix), do: {:error, changeset}
  def preload_asset_categories({:ok, scopes}, prefix), do: {:ok, preload_asset_categories(scopes, prefix)}
  def preload_asset_categories(scopes, prefix), do: Map.put(scopes, :asset_categories, get_resources_from_list(scopes.location_ids, Location, prefix))

  def get_resources_from_list(nil, query, prefix) do
    from(q in query, select: %{id: q.id, name: q.name})
    |> Repo.all(prefix: prefix)
  end

  def get_resources_from_list(list, query, prefix) do
    from(q in query, where: q.id in ^list, select: %{id: q.id, name: q.name})
    |> Repo.all(prefix: prefix)
  end
end
