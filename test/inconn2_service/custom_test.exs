defmodule Inconn2Service.CustomTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Custom

  describe "custom_fields" do
    alias Inconn2Service.Custom.CustomFields

    @valid_attrs %{entity: "some entity", fields: []}
    @update_attrs %{entity: "some updated entity", fields: []}
    @invalid_attrs %{entity: nil, fields: nil}

    def custom_fields_fixture(attrs \\ %{}) do
      {:ok, custom_fields} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Custom.create_custom_fields()

      custom_fields
    end

    test "list_custom_fields/0 returns all custom_fields" do
      custom_fields = custom_fields_fixture()
      assert Custom.list_custom_fields() == [custom_fields]
    end

    test "get_custom_fields!/1 returns the custom_fields with given id" do
      custom_fields = custom_fields_fixture()
      assert Custom.get_custom_fields!(custom_fields.id) == custom_fields
    end

    test "create_custom_fields/1 with valid data creates a custom_fields" do
      assert {:ok, %CustomFields{} = custom_fields} = Custom.create_custom_fields(@valid_attrs)
      assert custom_fields.entity == "some entity"
      assert custom_fields.fields == []
    end

    test "create_custom_fields/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Custom.create_custom_fields(@invalid_attrs)
    end

    test "update_custom_fields/2 with valid data updates the custom_fields" do
      custom_fields = custom_fields_fixture()
      assert {:ok, %CustomFields{} = custom_fields} = Custom.update_custom_fields(custom_fields, @update_attrs)
      assert custom_fields.entity == "some updated entity"
      assert custom_fields.fields == []
    end

    test "update_custom_fields/2 with invalid data returns error changeset" do
      custom_fields = custom_fields_fixture()
      assert {:error, %Ecto.Changeset{}} = Custom.update_custom_fields(custom_fields, @invalid_attrs)
      assert custom_fields == Custom.get_custom_fields!(custom_fields.id)
    end

    test "delete_custom_fields/1 deletes the custom_fields" do
      custom_fields = custom_fields_fixture()
      assert {:ok, %CustomFields{}} = Custom.delete_custom_fields(custom_fields)
      assert_raise Ecto.NoResultsError, fn -> Custom.get_custom_fields!(custom_fields.id) end
    end

    test "change_custom_fields/1 returns a custom_fields changeset" do
      custom_fields = custom_fields_fixture()
      assert %Ecto.Changeset{} = Custom.change_custom_fields(custom_fields)
    end
  end
end
