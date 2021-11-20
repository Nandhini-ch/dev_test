defmodule Inconn2ServiceWeb.WorkrequestStatusTrackControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.WorkrequestStatusTrack

  @create_attrs %{
    status: "some status",
    status_update_date: ~D[2010-04-17],
    status_update_time: ~T[14:00:00],
    user_id: 42
  }
  @update_attrs %{
    status: "some updated status",
    status_update_date: ~D[2011-05-18],
    status_update_time: ~T[15:01:01],
    user_id: 43
  }
  @invalid_attrs %{status: nil, status_update_date: nil, status_update_time: nil, user_id: nil}

  def fixture(:workrequest_status_track) do
    {:ok, workrequest_status_track} = Ticket.create_workrequest_status_track(@create_attrs)
    workrequest_status_track
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all workrequest_status_track", %{conn: conn} do
      conn = get(conn, Routes.workrequest_status_track_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create workrequest_status_track" do
    test "renders workrequest_status_track when data is valid", %{conn: conn} do
      conn = post(conn, Routes.workrequest_status_track_path(conn, :create), workrequest_status_track: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.workrequest_status_track_path(conn, :show, id))

      assert %{
               "id" => id,
               "status" => "some status",
               "status_update_date" => "2010-04-17",
               "status_update_time" => "14:00:00",
               "user_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.workrequest_status_track_path(conn, :create), workrequest_status_track: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update workrequest_status_track" do
    setup [:create_workrequest_status_track]

    test "renders workrequest_status_track when data is valid", %{conn: conn, workrequest_status_track: %WorkrequestStatusTrack{id: id} = workrequest_status_track} do
      conn = put(conn, Routes.workrequest_status_track_path(conn, :update, workrequest_status_track), workrequest_status_track: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workrequest_status_track_path(conn, :show, id))

      assert %{
               "id" => id,
               "status" => "some updated status",
               "status_update_date" => "2011-05-18",
               "status_update_time" => "15:01:01",
               "user_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, workrequest_status_track: workrequest_status_track} do
      conn = put(conn, Routes.workrequest_status_track_path(conn, :update, workrequest_status_track), workrequest_status_track: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete workrequest_status_track" do
    setup [:create_workrequest_status_track]

    test "deletes chosen workrequest_status_track", %{conn: conn, workrequest_status_track: workrequest_status_track} do
      conn = delete(conn, Routes.workrequest_status_track_path(conn, :delete, workrequest_status_track))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.workrequest_status_track_path(conn, :show, workrequest_status_track))
      end
    end
  end

  defp create_workrequest_status_track(_) do
    workrequest_status_track = fixture(:workrequest_status_track)
    %{workrequest_status_track: workrequest_status_track}
  end
end
