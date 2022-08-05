defmodule Inconn2Service.ContractManagementTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.ContractManagement

  describe "contracts" do
    alias Inconn2Service.ContractManagement.Contract

    @valid_attrs %{description: "some description", end_date: ~D[2010-04-17], name: "some name", start_date: ~D[2010-04-17]}
    @update_attrs %{description: "some updated description", end_date: ~D[2011-05-18], name: "some updated name", start_date: ~D[2011-05-18]}
    @invalid_attrs %{description: nil, end_date: nil, name: nil, start_date: nil}

    def contract_fixture(attrs \\ %{}) do
      {:ok, contract} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ContractManagement.create_contract()

      contract
    end

    test "list_contracts/0 returns all contracts" do
      contract = contract_fixture()
      assert ContractManagement.list_contracts() == [contract]
    end

    test "get_contract!/1 returns the contract with given id" do
      contract = contract_fixture()
      assert ContractManagement.get_contract!(contract.id) == contract
    end

    test "create_contract/1 with valid data creates a contract" do
      assert {:ok, %Contract{} = contract} = ContractManagement.create_contract(@valid_attrs)
      assert contract.description == "some description"
      assert contract.end_date == ~D[2010-04-17]
      assert contract.name == "some name"
      assert contract.start_date == ~D[2010-04-17]
    end

    test "create_contract/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ContractManagement.create_contract(@invalid_attrs)
    end

    test "update_contract/2 with valid data updates the contract" do
      contract = contract_fixture()
      assert {:ok, %Contract{} = contract} = ContractManagement.update_contract(contract, @update_attrs)
      assert contract.description == "some updated description"
      assert contract.end_date == ~D[2011-05-18]
      assert contract.name == "some updated name"
      assert contract.start_date == ~D[2011-05-18]
    end

    test "update_contract/2 with invalid data returns error changeset" do
      contract = contract_fixture()
      assert {:error, %Ecto.Changeset{}} = ContractManagement.update_contract(contract, @invalid_attrs)
      assert contract == ContractManagement.get_contract!(contract.id)
    end

    test "delete_contract/1 deletes the contract" do
      contract = contract_fixture()
      assert {:ok, %Contract{}} = ContractManagement.delete_contract(contract)
      assert_raise Ecto.NoResultsError, fn -> ContractManagement.get_contract!(contract.id) end
    end

    test "change_contract/1 returns a contract changeset" do
      contract = contract_fixture()
      assert %Ecto.Changeset{} = ContractManagement.change_contract(contract)
    end
  end

  describe "scopes" do
    alias Inconn2Service.ContractManagement.Scope

    @valid_attrs %{applicable_to_all_asset_category: true, applicable_to_all_location: true, asset_category_ids: [], location_ids: []}
    @update_attrs %{applicable_to_all_asset_category: false, applicable_to_all_location: false, asset_category_ids: [], location_ids: []}
    @invalid_attrs %{applicable_to_all_asset_category: nil, applicable_to_all_location: nil, asset_category_ids: nil, location_ids: nil}

    def scope_fixture(attrs \\ %{}) do
      {:ok, scope} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ContractManagement.create_scope()

      scope
    end

    test "list_scopes/0 returns all scopes" do
      scope = scope_fixture()
      assert ContractManagement.list_scopes() == [scope]
    end

    test "get_scope!/1 returns the scope with given id" do
      scope = scope_fixture()
      assert ContractManagement.get_scope!(scope.id) == scope
    end

    test "create_scope/1 with valid data creates a scope" do
      assert {:ok, %Scope{} = scope} = ContractManagement.create_scope(@valid_attrs)
      assert scope.applicable_to_all_asset_category == true
      assert scope.applicable_to_all_location == true
      assert scope.asset_category_ids == []
      assert scope.location_ids == []
    end

    test "create_scope/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ContractManagement.create_scope(@invalid_attrs)
    end

    test "update_scope/2 with valid data updates the scope" do
      scope = scope_fixture()
      assert {:ok, %Scope{} = scope} = ContractManagement.update_scope(scope, @update_attrs)
      assert scope.applicable_to_all_asset_category == false
      assert scope.applicable_to_all_location == false
      assert scope.asset_category_ids == []
      assert scope.location_ids == []
    end

    test "update_scope/2 with invalid data returns error changeset" do
      scope = scope_fixture()
      assert {:error, %Ecto.Changeset{}} = ContractManagement.update_scope(scope, @invalid_attrs)
      assert scope == ContractManagement.get_scope!(scope.id)
    end

    test "delete_scope/1 deletes the scope" do
      scope = scope_fixture()
      assert {:ok, %Scope{}} = ContractManagement.delete_scope(scope)
      assert_raise Ecto.NoResultsError, fn -> ContractManagement.get_scope!(scope.id) end
    end

    test "change_scope/1 returns a scope changeset" do
      scope = scope_fixture()
      assert %Ecto.Changeset{} = ContractManagement.change_scope(scope)
    end
  end
end
