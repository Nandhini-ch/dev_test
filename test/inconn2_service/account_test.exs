defmodule Inconn2Service.AccountTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Account

  describe "business_types" do
    alias Inconn2Service.Account.BusinessType

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def business_type_fixture(attrs \\ %{}) do
      {:ok, business_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_business_type()

      business_type
    end

    test "list_business_types/0 returns all business_types" do
      business_type = business_type_fixture()
      assert Account.list_business_types() == [business_type]
    end

    test "get_business_type!/1 returns the business_type with given id" do
      business_type = business_type_fixture()
      assert Account.get_business_type!(business_type.id) == business_type
    end

    test "create_business_type/1 with valid data creates a business_type" do
      assert {:ok, %BusinessType{} = business_type} = Account.create_business_type(@valid_attrs)
      assert business_type.description == "some description"
      assert business_type.name == "some name"
    end

    test "create_business_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_business_type(@invalid_attrs)
    end

    test "update_business_type/2 with valid data updates the business_type" do
      business_type = business_type_fixture()
      assert {:ok, %BusinessType{} = business_type} = Account.update_business_type(business_type, @update_attrs)
      assert business_type.description == "some updated description"
      assert business_type.name == "some updated name"
    end

    test "update_business_type/2 with invalid data returns error changeset" do
      business_type = business_type_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_business_type(business_type, @invalid_attrs)
      assert business_type == Account.get_business_type!(business_type.id)
    end

    test "delete_business_type/1 deletes the business_type" do
      business_type = business_type_fixture()
      assert {:ok, %BusinessType{}} = Account.delete_business_type(business_type)
      assert_raise Ecto.NoResultsError, fn -> Account.get_business_type!(business_type.id) end
    end

    test "change_business_type/1 returns a business_type changeset" do
      business_type = business_type_fixture()
      assert %Ecto.Changeset{} = Account.change_business_type(business_type)
    end
  end

  describe "licensees" do
    alias Inconn2Service.Account.Licensee

    @valid_attrs %{address: %{}, business_types: "some business_types", company_name: "some company_name", contact: %{}}
    @update_attrs %{address: %{}, business_types: "some updated business_types", company_name: "some updated company_name", contact: %{}}
    @invalid_attrs %{address: nil, business_types: nil, company_name: nil, contact: nil}

    def licensee_fixture(attrs \\ %{}) do
      {:ok, licensee} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_licensee()

      licensee
    end

    test "list_licensees/0 returns all licensees" do
      licensee = licensee_fixture()
      assert Account.list_licensees() == [licensee]
    end

    test "get_licensee!/1 returns the licensee with given id" do
      licensee = licensee_fixture()
      assert Account.get_licensee!(licensee.id) == licensee
    end

    test "create_licensee/1 with valid data creates a licensee" do
      assert {:ok, %Licensee{} = licensee} = Account.create_licensee(@valid_attrs)
      assert licensee.address == %{}
      assert licensee.business_types == "some business_types"
      assert licensee.company_name == "some company_name"
      assert licensee.contact == %{}
    end

    test "create_licensee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_licensee(@invalid_attrs)
    end

    test "update_licensee/2 with valid data updates the licensee" do
      licensee = licensee_fixture()
      assert {:ok, %Licensee{} = licensee} = Account.update_licensee(licensee, @update_attrs)
      assert licensee.address == %{}
      assert licensee.business_types == "some updated business_types"
      assert licensee.company_name == "some updated company_name"
      assert licensee.contact == %{}
    end

    test "update_licensee/2 with invalid data returns error changeset" do
      licensee = licensee_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_licensee(licensee, @invalid_attrs)
      assert licensee == Account.get_licensee!(licensee.id)
    end

    test "delete_licensee/1 deletes the licensee" do
      licensee = licensee_fixture()
      assert {:ok, %Licensee{}} = Account.delete_licensee(licensee)
      assert_raise Ecto.NoResultsError, fn -> Account.get_licensee!(licensee.id) end
    end

    test "change_licensee/1 returns a licensee changeset" do
      licensee = licensee_fixture()
      assert %Ecto.Changeset{} = Account.change_licensee(licensee)
    end
  end
end
