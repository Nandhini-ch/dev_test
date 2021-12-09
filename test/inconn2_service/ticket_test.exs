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

  describe "category_helpdesks" do
    alias Inconn2Service.Ticket.CategoryHelpdesk

    @valid_attrs %{user_id: 42}
    @update_attrs %{user_id: 43}
    @invalid_attrs %{user_id: nil}

    def category_helpdesk_fixture(attrs \\ %{}) do
      {:ok, category_helpdesk} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ticket.create_category_helpdesk()

      category_helpdesk
    end

    test "list_category_helpdesks/0 returns all category_helpdesks" do
      category_helpdesk = category_helpdesk_fixture()
      assert Ticket.list_category_helpdesks() == [category_helpdesk]
    end

    test "get_category_helpdesk!/1 returns the category_helpdesk with given id" do
      category_helpdesk = category_helpdesk_fixture()
      assert Ticket.get_category_helpdesk!(category_helpdesk.id) == category_helpdesk
    end

    test "create_category_helpdesk/1 with valid data creates a category_helpdesk" do
      assert {:ok, %CategoryHelpdesk{} = category_helpdesk} = Ticket.create_category_helpdesk(@valid_attrs)
      assert category_helpdesk.user_id == 42
    end

    test "create_category_helpdesk/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ticket.create_category_helpdesk(@invalid_attrs)
    end

    test "update_category_helpdesk/2 with valid data updates the category_helpdesk" do
      category_helpdesk = category_helpdesk_fixture()
      assert {:ok, %CategoryHelpdesk{} = category_helpdesk} = Ticket.update_category_helpdesk(category_helpdesk, @update_attrs)
      assert category_helpdesk.user_id == 43
    end

    test "update_category_helpdesk/2 with invalid data returns error changeset" do
      category_helpdesk = category_helpdesk_fixture()
      assert {:error, %Ecto.Changeset{}} = Ticket.update_category_helpdesk(category_helpdesk, @invalid_attrs)
      assert category_helpdesk == Ticket.get_category_helpdesk!(category_helpdesk.id)
    end

    test "delete_category_helpdesk/1 deletes the category_helpdesk" do
      category_helpdesk = category_helpdesk_fixture()
      assert {:ok, %CategoryHelpdesk{}} = Ticket.delete_category_helpdesk(category_helpdesk)
      assert_raise Ecto.NoResultsError, fn -> Ticket.get_category_helpdesk!(category_helpdesk.id) end
    end

    test "change_category_helpdesk/1 returns a category_helpdesk changeset" do
      category_helpdesk = category_helpdesk_fixture()
      assert %Ecto.Changeset{} = Ticket.change_category_helpdesk(category_helpdesk)
    end
  end

  describe "workrequest_status_track" do
    alias Inconn2Service.Ticket.WorkrequestStatusTrack

    @valid_attrs %{status: "some status", status_update_date: ~D[2010-04-17], status_update_time: ~T[14:00:00], user_id: 42}
    @update_attrs %{status: "some updated status", status_update_date: ~D[2011-05-18], status_update_time: ~T[15:01:01], user_id: 43}
    @invalid_attrs %{status: nil, status_update_date: nil, status_update_time: nil, user_id: nil}

    def workrequest_status_track_fixture(attrs \\ %{}) do
      {:ok, workrequest_status_track} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ticket.create_workrequest_status_track()

      workrequest_status_track
    end

    test "list_workrequest_status_track/0 returns all workrequest_status_track" do
      workrequest_status_track = workrequest_status_track_fixture()
      assert Ticket.list_workrequest_status_track() == [workrequest_status_track]
    end

    test "get_workrequest_status_track!/1 returns the workrequest_status_track with given id" do
      workrequest_status_track = workrequest_status_track_fixture()
      assert Ticket.get_workrequest_status_track!(workrequest_status_track.id) == workrequest_status_track
    end

    test "create_workrequest_status_track/1 with valid data creates a workrequest_status_track" do
      assert {:ok, %WorkrequestStatusTrack{} = workrequest_status_track} = Ticket.create_workrequest_status_track(@valid_attrs)
      assert workrequest_status_track.status == "some status"
      assert workrequest_status_track.status_update_date == ~D[2010-04-17]
      assert workrequest_status_track.status_update_time == ~T[14:00:00]
      assert workrequest_status_track.user_id == 42
    end

    test "create_workrequest_status_track/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ticket.create_workrequest_status_track(@invalid_attrs)
    end

    test "update_workrequest_status_track/2 with valid data updates the workrequest_status_track" do
      workrequest_status_track = workrequest_status_track_fixture()
      assert {:ok, %WorkrequestStatusTrack{} = workrequest_status_track} = Ticket.update_workrequest_status_track(workrequest_status_track, @update_attrs)
      assert workrequest_status_track.status == "some updated status"
      assert workrequest_status_track.status_update_date == ~D[2011-05-18]
      assert workrequest_status_track.status_update_time == ~T[15:01:01]
      assert workrequest_status_track.user_id == 43
    end

    test "update_workrequest_status_track/2 with invalid data returns error changeset" do
      workrequest_status_track = workrequest_status_track_fixture()
      assert {:error, %Ecto.Changeset{}} = Ticket.update_workrequest_status_track(workrequest_status_track, @invalid_attrs)
      assert workrequest_status_track == Ticket.get_workrequest_status_track!(workrequest_status_track.id)
    end

    test "delete_workrequest_status_track/1 deletes the workrequest_status_track" do
      workrequest_status_track = workrequest_status_track_fixture()
      assert {:ok, %WorkrequestStatusTrack{}} = Ticket.delete_workrequest_status_track(workrequest_status_track)
      assert_raise Ecto.NoResultsError, fn -> Ticket.get_workrequest_status_track!(workrequest_status_track.id) end
    end

    test "change_workrequest_status_track/1 returns a workrequest_status_track changeset" do
      workrequest_status_track = workrequest_status_track_fixture()
      assert %Ecto.Changeset{} = Ticket.change_workrequest_status_track(workrequest_status_track)
    end
  end

  describe "approvals" do
    alias Inconn2Service.Ticket.Approval

    @valid_attrs %{approved: true, remarks: "some remarks", user_id: 42}
    @update_attrs %{approved: false, remarks: "some updated remarks", user_id: 43}
    @invalid_attrs %{approved: nil, remarks: nil, user_id: nil}

    def approval_fixture(attrs \\ %{}) do
      {:ok, approval} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ticket.create_approval()

      approval
    end

    test "list_approvals/0 returns all approvals" do
      approval = approval_fixture()
      assert Ticket.list_approvals() == [approval]
    end

    test "get_approval!/1 returns the approval with given id" do
      approval = approval_fixture()
      assert Ticket.get_approval!(approval.id) == approval
    end

    test "create_approval/1 with valid data creates a approval" do
      assert {:ok, %Approval{} = approval} = Ticket.create_approval(@valid_attrs)
      assert approval.approved == true
      assert approval.remarks == "some remarks"
      assert approval.user_id == 42
    end

    test "create_approval/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ticket.create_approval(@invalid_attrs)
    end

    test "update_approval/2 with valid data updates the approval" do
      approval = approval_fixture()
      assert {:ok, %Approval{} = approval} = Ticket.update_approval(approval, @update_attrs)
      assert approval.approved == false
      assert approval.remarks == "some updated remarks"
      assert approval.user_id == 43
    end

    test "update_approval/2 with invalid data returns error changeset" do
      approval = approval_fixture()
      assert {:error, %Ecto.Changeset{}} = Ticket.update_approval(approval, @invalid_attrs)
      assert approval == Ticket.get_approval!(approval.id)
    end

    test "delete_approval/1 deletes the approval" do
      approval = approval_fixture()
      assert {:ok, %Approval{}} = Ticket.delete_approval(approval)
      assert_raise Ecto.NoResultsError, fn -> Ticket.get_approval!(approval.id) end
    end

    test "change_approval/1 returns a approval changeset" do
      approval = approval_fixture()
      assert %Ecto.Changeset{} = Ticket.change_approval(approval)
    end
  end

  describe "workrequest_subcategories" do
    alias Inconn2Service.Ticket.WorkrequestSubcategory

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def workrequest_subcategory_fixture(attrs \\ %{}) do
      {:ok, workrequest_subcategory} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ticket.create_workrequest_subcategory()

      workrequest_subcategory
    end

    test "list_workrequest_subcategories/0 returns all workrequest_subcategories" do
      workrequest_subcategory = workrequest_subcategory_fixture()
      assert Ticket.list_workrequest_subcategories() == [workrequest_subcategory]
    end

    test "get_workrequest_subcategory!/1 returns the workrequest_subcategory with given id" do
      workrequest_subcategory = workrequest_subcategory_fixture()
      assert Ticket.get_workrequest_subcategory!(workrequest_subcategory.id) == workrequest_subcategory
    end

    test "create_workrequest_subcategory/1 with valid data creates a workrequest_subcategory" do
      assert {:ok, %WorkrequestSubcategory{} = workrequest_subcategory} = Ticket.create_workrequest_subcategory(@valid_attrs)
      assert workrequest_subcategory.description == "some description"
      assert workrequest_subcategory.name == "some name"
    end

    test "create_workrequest_subcategory/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ticket.create_workrequest_subcategory(@invalid_attrs)
    end

    test "update_workrequest_subcategory/2 with valid data updates the workrequest_subcategory" do
      workrequest_subcategory = workrequest_subcategory_fixture()
      assert {:ok, %WorkrequestSubcategory{} = workrequest_subcategory} = Ticket.update_workrequest_subcategory(workrequest_subcategory, @update_attrs)
      assert workrequest_subcategory.description == "some updated description"
      assert workrequest_subcategory.name == "some updated name"
    end

    test "update_workrequest_subcategory/2 with invalid data returns error changeset" do
      workrequest_subcategory = workrequest_subcategory_fixture()
      assert {:error, %Ecto.Changeset{}} = Ticket.update_workrequest_subcategory(workrequest_subcategory, @invalid_attrs)
      assert workrequest_subcategory == Ticket.get_workrequest_subcategory!(workrequest_subcategory.id)
    end

    test "delete_workrequest_subcategory/1 deletes the workrequest_subcategory" do
      workrequest_subcategory = workrequest_subcategory_fixture()
      assert {:ok, %WorkrequestSubcategory{}} = Ticket.delete_workrequest_subcategory(workrequest_subcategory)
      assert_raise Ecto.NoResultsError, fn -> Ticket.get_workrequest_subcategory!(workrequest_subcategory.id) end
    end

    test "change_workrequest_subcategory/1 returns a workrequest_subcategory changeset" do
      workrequest_subcategory = workrequest_subcategory_fixture()
      assert %Ecto.Changeset{} = Ticket.change_workrequest_subcategory(workrequest_subcategory)
    end
  end
end
