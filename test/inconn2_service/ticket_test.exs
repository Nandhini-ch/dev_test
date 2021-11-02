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

  describe "work_requests" do
    alias Inconn2Service.Ticket.WorkRequest

    @valid_attrs %{site_id: 42, workrequest_category_id: 42}
    @update_attrs %{site_id: 43, workrequest_category_id: 43}
    @invalid_attrs %{site_id: nil, workrequest_category_id: nil}

    def work_request_fixture(attrs \\ %{}) do
      {:ok, work_request} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ticket.create_work_request()

      work_request
    end

    test "list_work_requests/0 returns all work_requests" do
      work_request = work_request_fixture()
      assert Ticket.list_work_requests() == [work_request]
    end

    test "get_work_request!/1 returns the work_request with given id" do
      work_request = work_request_fixture()
      assert Ticket.get_work_request!(work_request.id) == work_request
    end

    test "create_work_request/1 with valid data creates a work_request" do
      assert {:ok, %WorkRequest{} = work_request} = Ticket.create_work_request(@valid_attrs)
      assert work_request.site_id == 42
      assert work_request.workrequest_category_id == 42
    end

    test "create_work_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ticket.create_work_request(@invalid_attrs)
    end

    test "update_work_request/2 with valid data updates the work_request" do
      work_request = work_request_fixture()
      assert {:ok, %WorkRequest{} = work_request} = Ticket.update_work_request(work_request, @update_attrs)
      assert work_request.site_id == 43
      assert work_request.workrequest_category_id == 43
    end

    test "update_work_request/2 with invalid data returns error changeset" do
      work_request = work_request_fixture()
      assert {:error, %Ecto.Changeset{}} = Ticket.update_work_request(work_request, @invalid_attrs)
      assert work_request == Ticket.get_work_request!(work_request.id)
    end

    test "delete_work_request/1 deletes the work_request" do
      work_request = work_request_fixture()
      assert {:ok, %WorkRequest{}} = Ticket.delete_work_request(work_request)
      assert_raise Ecto.NoResultsError, fn -> Ticket.get_work_request!(work_request.id) end
    end

    test "change_work_request/1 returns a work_request changeset" do
      work_request = work_request_fixture()
      assert %Ecto.Changeset{} = Ticket.change_work_request(work_request)
    end
  end
end
