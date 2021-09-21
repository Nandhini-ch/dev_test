defmodule Inconn2Service.TicketTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Ticket

  describe "workrequest_categories" do
    alias Inconn2Service.Ticket.WorkrequestCategory

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def workrequest_category_fixture(attrs \\ %{}) do
      {:ok, workrequest_category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ticket.create_workrequest_category()

      workrequest_category
    end

    test "list_workrequest_categories/0 returns all workrequest_categories" do
      workrequest_category = workrequest_category_fixture()
      assert Ticket.list_workrequest_categories() == [workrequest_category]
    end

    test "get_workrequest_category!/1 returns the workrequest_category with given id" do
      workrequest_category = workrequest_category_fixture()
      assert Ticket.get_workrequest_category!(workrequest_category.id) == workrequest_category
    end

    test "create_workrequest_category/1 with valid data creates a workrequest_category" do
      assert {:ok, %WorkrequestCategory{} = workrequest_category} = Ticket.create_workrequest_category(@valid_attrs)
      assert workrequest_category.description == "some description"
      assert workrequest_category.name == "some name"
    end

    test "create_workrequest_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ticket.create_workrequest_category(@invalid_attrs)
    end

    test "update_workrequest_category/2 with valid data updates the workrequest_category" do
      workrequest_category = workrequest_category_fixture()
      assert {:ok, %WorkrequestCategory{} = workrequest_category} = Ticket.update_workrequest_category(workrequest_category, @update_attrs)
      assert workrequest_category.description == "some updated description"
      assert workrequest_category.name == "some updated name"
    end

    test "update_workrequest_category/2 with invalid data returns error changeset" do
      workrequest_category = workrequest_category_fixture()
      assert {:error, %Ecto.Changeset{}} = Ticket.update_workrequest_category(workrequest_category, @invalid_attrs)
      assert workrequest_category == Ticket.get_workrequest_category!(workrequest_category.id)
    end

    test "delete_workrequest_category/1 deletes the workrequest_category" do
      workrequest_category = workrequest_category_fixture()
      assert {:ok, %WorkrequestCategory{}} = Ticket.delete_workrequest_category(workrequest_category)
      assert_raise Ecto.NoResultsError, fn -> Ticket.get_workrequest_category!(workrequest_category.id) end
    end

    test "change_workrequest_category/1 returns a workrequest_category changeset" do
      workrequest_category = workrequest_category_fixture()
      assert %Ecto.Changeset{} = Ticket.change_workrequest_category(workrequest_category)
    end
  end
end
