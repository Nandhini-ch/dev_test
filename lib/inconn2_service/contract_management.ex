defmodule Inconn2Service.ContractManagement do
  @moduledoc """
  The ContractManagement context.
  """

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.ContractManagement.Contract


  def list_contracts(_params, prefix) do
    Repo.all(Contract, prefix: prefix)
  end

  def get_contract!(id, prefix), do: Repo.get!(Contract, id, prefix: prefix)


  def create_contract(attrs \\ %{}, prefix) do
    %Contract{}
    |> Contract.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_contract(%Contract{} = contract, attrs, prefix) do
    contract
    |> Contract.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end


  def delete_contract(%Contract{} = contract, prefix) do
    Repo.delete(contract, prefix: prefix)
  end


  def change_contract(%Contract{} = contract, attrs \\ %{}) do
    Contract.changeset(contract, attrs)
  end

  alias Inconn2Service.ContractManagement.Scope


  def list_scopes(_params, prefix) do
    Repo.all(Scope, prefix: prefix)
  end


  def get_scope!(id, prefix), do: Repo.get!(Scope, id, prefix: prefix)


  def create_scope(attrs \\ %{}, prefix) do
    %Scope{}
    |> Scope.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end


  def update_scope(%Scope{} = scope, attrs, prefix) do
    scope
    |> Scope.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_scope(%Scope{} = scope, prefix) do
    Repo.delete(scope, prefix: prefix)
  end

  def change_scope(%Scope{} = scope, attrs \\ %{}) do
    Scope.changeset(scope, attrs)
  end
end
