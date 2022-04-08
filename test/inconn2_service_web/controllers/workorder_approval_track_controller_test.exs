defmodule Inconn2ServiceWeb.WorkorderApprovalTrackControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkorderApprovalTrack

  @create_attrs %{
    approved: true,
    discrepancy_workorder_check_ids: [],
    remarks: "some remarks",
    type: "some type"
  }
  @update_attrs %{
    approved: false,
    discrepancy_workorder_check_ids: [],
    remarks: "some updated remarks",
    type: "some updated type"
  }
  @invalid_attrs %{approved: nil, discrepancy_workorder_check_ids: nil, remarks: nil, type: nil}

  def fixture(:workorder_approval_track) do
    {:ok, workorder_approval_track} = Workorder.create_workorder_approval_track(@create_attrs)
    workorder_approval_track
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all workorder_approval_tracks", %{conn: conn} do
      conn = get(conn, Routes.workorder_approval_track_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create workorder_approval_track" do
    test "renders workorder_approval_track when data is valid", %{conn: conn} do
      conn = post(conn, Routes.workorder_approval_track_path(conn, :create), workorder_approval_track: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.workorder_approval_track_path(conn, :show, id))

      assert %{
               "id" => id,
               "approved" => true,
               "discrepancy_workorder_check_ids" => [],
               "remarks" => "some remarks",
               "type" => "some type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.workorder_approval_track_path(conn, :create), workorder_approval_track: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update workorder_approval_track" do
    setup [:create_workorder_approval_track]

    test "renders workorder_approval_track when data is valid", %{conn: conn, workorder_approval_track: %WorkorderApprovalTrack{id: id} = workorder_approval_track} do
      conn = put(conn, Routes.workorder_approval_track_path(conn, :update, workorder_approval_track), workorder_approval_track: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workorder_approval_track_path(conn, :show, id))

      assert %{
               "id" => id,
               "approved" => false,
               "discrepancy_workorder_check_ids" => [],
               "remarks" => "some updated remarks",
               "type" => "some updated type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, workorder_approval_track: workorder_approval_track} do
      conn = put(conn, Routes.workorder_approval_track_path(conn, :update, workorder_approval_track), workorder_approval_track: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete workorder_approval_track" do
    setup [:create_workorder_approval_track]

    test "deletes chosen workorder_approval_track", %{conn: conn, workorder_approval_track: workorder_approval_track} do
      conn = delete(conn, Routes.workorder_approval_track_path(conn, :delete, workorder_approval_track))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.workorder_approval_track_path(conn, :show, workorder_approval_track))
      end
    end
  end

  defp create_workorder_approval_track(_) do
    workorder_approval_track = fixture(:workorder_approval_track)
    %{workorder_approval_track: workorder_approval_track}
  end
end
