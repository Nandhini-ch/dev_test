defmodule Inconn2Service.ContractManagement do
  # import Ecto.Changeset
  # import Inconn2Service.Util.IndexQueries
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo
  alias Inconn2Service.ContractManagement.Scope
  alias Inconn2Service.ContractManagement.Contract


  def list_contracts(_params, prefix) do
    Contract
    |> Repo.all(prefix: prefix)
    |> Repo.preload(:scopes)
  end

  def get_contract!(id, prefix), do: Repo.get!(Contract, id, prefix: prefix) |> Repo.preload(:scopes)


  def create_contract(attrs \\ %{}, prefix) do
    %Contract{}
    |> Contract.changeset(attrs)
    |> Repo.insert(prefix: prefix)
    |> preload_scopes()
  end

  def update_contract(%Contract{} = contract, attrs, prefix) do
    contract
    |> Contract.changeset(attrs)
    |> Repo.update(prefix: prefix)
    |> preload_scopes()
  end


  def delete_contract(%Contract{} = contract, prefix) do
    Repo.delete(contract, prefix: prefix)
  end


  def change_contract(%Contract{} = contract, attrs \\ %{}) do
    Contract.changeset(contract, attrs)
  end


  def list_scopes(_params, prefix) do
    Repo.all(Scope, prefix: prefix)
  end


  def get_scope!(id, prefix), do: Repo.get!(Scope, id, prefix: prefix)

  def create_scope(attrs, query_params, prefix) do
    insert_scope(attrs, query_params["type"], prefix)
  end

  def create_scope(attrs, prefix) do
    %Scope{}
    |> Scope.changeset(attrs)
    # |> validate_party_type(prefix)
    |> Repo.insert(prefix: prefix)
  end

  def update_scope(%Scope{} = scope, attrs, prefix) do
    scope
    |> Scope.changeset(attrs)
    # |> validate_party_type(prefix)
    |> Repo.update(prefix: prefix)
  end

  def delete_scope(%Scope{} = scope, prefix) do
    Repo.delete(scope, prefix: prefix)
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

  defp preload_scopes({:error, changeset}), do: {:error, changeset}
  defp preload_scopes({:ok, contract}), do: {:ok, contract |> Repo.preload(:scopes)}

end
