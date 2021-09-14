defmodule Inconn2ServiceWeb.WorkorderStatusTrackControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkorderStatusTrack

  @create_attrs %{
    status: "some status",
    work_order_id: 42
  }
  @update_attrs %{
    status: "some updated status",
    work_order_id: 43
  }
  @invalid_attrs %{status: nil, work_order_id: nil}

  def fixture(:workorder_status_track) do
    {:ok, workorder_status_track} = Workorder.create_workorder_status_track(@create_attrs)
    workorder_status_track
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all workorder_status_tracks", %{conn: conn} do
      conn = get(conn, Routes.workorder_status_track_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create workorder_status_track" do
    test "renders workorder_status_track when data is valid", %{conn: conn} do
      conn = post(conn, Routes.workorder_status_track_path(conn, :create), workorder_status_track: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.workorder_status_track_path(conn, :show, id))

      assert %{
               "id" => id,
               "status" => "some status",
               "work_order_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.workorder_status_track_path(conn, :create), workorder_status_track: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update workorder_status_track" do
    setup [:create_workorder_status_track]

    test "renders workorder_status_track when data is valid", %{conn: conn, workorder_status_track: %WorkorderStatusTrack{id: id} = workorder_status_track} do
      conn = put(conn, Routes.workorder_status_track_path(conn, :update, workorder_status_track), workorder_status_track: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workorder_status_track_path(conn, :show, id))

      assert %{
               "id" => id,
               "status" => "some updated status",
               "work_order_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, workorder_status_track: workorder_status_track} do
      conn = put(conn, Routes.workorder_status_track_path(conn, :update, workorder_status_track), workorder_status_track: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete workorder_status_track" do
    setup [:create_workorder_status_track]

    test "deletes chosen workorder_status_track", %{conn: conn, workorder_status_track: workorder_status_track} do
      conn = delete(conn, Routes.workorder_status_track_path(conn, :delete, workorder_status_track))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.workorder_status_track_path(conn, :show, workorder_status_track))
      end
    end
  end

  defp create_workorder_status_track(_) do
    workorder_status_track = fixture(:workorder_status_track)
    %{workorder_status_track: workorder_status_track}
  end
end
