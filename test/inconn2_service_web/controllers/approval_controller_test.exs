defmodule Inconn2ServiceWeb.ApprovalControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.Approval

  @create_attrs %{
    approved: true,
    remarks: "some remarks",
    user_id: 42
  }
  @update_attrs %{
    approved: false,
    remarks: "some updated remarks",
    user_id: 43
  }
  @invalid_attrs %{approved: nil, remarks: nil, user_id: nil}

  def fixture(:approval) do
    {:ok, approval} = Ticket.create_approval(@create_attrs)
    approval
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all approvals", %{conn: conn} do
      conn = get(conn, Routes.approval_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create approval" do
    test "renders approval when data is valid", %{conn: conn} do
      conn = post(conn, Routes.approval_path(conn, :create), approval: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.approval_path(conn, :show, id))

      assert %{
               "id" => id,
               "approved" => true,
               "remarks" => "some remarks",
               "user_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.approval_path(conn, :create), approval: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update approval" do
    setup [:create_approval]

    test "renders approval when data is valid", %{conn: conn, approval: %Approval{id: id} = approval} do
      conn = put(conn, Routes.approval_path(conn, :update, approval), approval: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.approval_path(conn, :show, id))

      assert %{
               "id" => id,
               "approved" => false,
               "remarks" => "some updated remarks",
               "user_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, approval: approval} do
      conn = put(conn, Routes.approval_path(conn, :update, approval), approval: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete approval" do
    setup [:create_approval]

    test "deletes chosen approval", %{conn: conn, approval: approval} do
      conn = delete(conn, Routes.approval_path(conn, :delete, approval))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.approval_path(conn, :show, approval))
      end
    end
  end

  defp create_approval(_) do
    approval = fixture(:approval)
    %{approval: approval}
  end
end
