defmodule Inconn2Service.ContractManagement do
  import Ecto.Changeset
  import Inconn2Service.Util.DeleteManager
  # import Inconn2Service.Util.IndexQueries
  # import Inconn2Service.Util.HelpersFunctions
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.ContractManagement.Scope
  alias Inconn2Service.ContractManagement.Contract

  def list_contracts(_params, prefix) do
    Repo.all(Contract, prefix: prefix)
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


  def list_scopes(_params, prefix) do
    Repo.all(Scope, prefix: prefix)
  end


  def get_scope!(id, prefix), do: Repo.get!(Scope, id, prefix: prefix)


  def create_scope(attrs \\ %{}, prefix) do
    %Scope{}
    |> Scope.changeset(attrs)
    |> validate_start_date(prefix)
    |> validate_end_date(prefix)
    |> validate_applicable_loc_ids()
    |> validate_applicable_asset_category_ids()
    |> validate_party_type(prefix)
    |> Repo.insert(prefix: prefix)
  end


  def update_scope(%Scope{} = scope, attrs, prefix) do
    scope
    |> Scope.changeset(attrs)
    |> validate_start_date(prefix)
    |> validate_end_date(prefix)
    |> validate_applicable_loc_ids()
    |> validate_applicable_asset_category_ids()
    |> validate_party_type(prefix)
    |> Repo.update(prefix: prefix)
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


  defp validate_start_date(cs, prefix) do
    contract_id = get_field(cs, :contract_id, nil)
    start_date = get_field(cs, :start_date, nil)
    contract = if is_nil(contract_id) do nil else get_contract!(contract_id, prefix) end
    cond do
      !is_nil(contract_id) && !is_nil(contract) && !is_nil(start_date) && contract.start_date >= start_date ->
        cs
      !is_nil(contract_id) && !is_nil(contract) && !is_nil(start_date) ->
        add_error(cs, :start_date, "Start date should be greater than contract start date(#{contract.start_date})")
      true ->
        cs
    end
  end

  defp validate_end_date(cs, prefix) do
    contract_id = get_field(cs, :contract_id, nil)
    end_date = get_field(cs, :end_date, nil)
    contract = if is_nil(contract_id) do nil else get_contract!(contract_id, prefix) end
    cond do
      !is_nil(contract_id) && !is_nil(contract) && !is_nil(end_date) && end_date <= contract.end_date ->
        cs
      !is_nil(contract_id) && !is_nil(contract) && !is_nil(end_date) ->
        add_error(cs, :end_date, "End date should be lesser than contract end date(#{contract.end_date})")
      true ->
        cs
    end
  end

  def validate_applicable_loc_ids(cs) do
    case get_field(cs, :is_applicable_to_all_location) do
      false -> validate_required(cs, [:location_ids])
      _ -> cs
    end
  end

  def validate_applicable_asset_category_ids(cs) do
    case get_field(cs, :is_applicable_to_all_asset_category) do
      false -> validate_required(cs, [:asset_category_ids])
      _ -> cs
    end
  end

  def validate_party_type(cs, prefix) do
   party_id = get_field(cs, :party_id)
   party = AssetConfig.get_party!(party_id, prefix)
   if party.type == "SP" do
     cs
    else
      add_error(cs, :party_id, "Party should be SP")
    end
  end

  defp preload_scopes({:error, changeset}), do: {:error, changeset}
  defp preload_scopes({:ok, contract}), do: {:ok, contract |> Repo.preload(:scopes)}

end
