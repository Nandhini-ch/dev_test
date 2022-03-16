defmodule Inconn2ServiceWeb.AssetStatusTrackControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.AssetStatusTrack

  @create_attrs %{
    asset_id: 42,
    asset_type: "some asset_type",
    changed_date_time: ~N[2010-04-17 14:00:00],
    status_changed: "some status_changed",
    user_id: 42
  }
  @update_attrs %{
    asset_id: 43,
    asset_type: "some updated asset_type",
    changed_date_time: ~N[2011-05-18 15:01:01],
    status_changed: "some updated status_changed",
    user_id: 43
  }
  @invalid_attrs %{asset_id: nil, asset_type: nil, changed_date_time: nil, status_changed: nil, user_id: nil}

  def fixture(:asset_status_track) do
    {:ok, asset_status_track} = AssetConfig.create_asset_status_track(@create_attrs)
    asset_status_track
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all asset_status_tracks", %{conn: conn} do
      conn = get(conn, Routes.asset_status_track_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create asset_status_track" do
    test "renders asset_status_track when data is valid", %{conn: conn} do
      conn = post(conn, Routes.asset_status_track_path(conn, :create), asset_status_track: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.asset_status_track_path(conn, :show, id))

      assert %{
               "id" => id,
               "asset_id" => 42,
               "asset_type" => "some asset_type",
               "changed_date_time" => "2010-04-17T14:00:00",
               "status_changed" => "some status_changed",
               "user_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.asset_status_track_path(conn, :create), asset_status_track: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update asset_status_track" do
    setup [:create_asset_status_track]

    test "renders asset_status_track when data is valid", %{conn: conn, asset_status_track: %AssetStatusTrack{id: id} = asset_status_track} do
      conn = put(conn, Routes.asset_status_track_path(conn, :update, asset_status_track), asset_status_track: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.asset_status_track_path(conn, :show, id))

      assert %{
               "id" => id,
               "asset_id" => 43,
               "asset_type" => "some updated asset_type",
               "changed_date_time" => "2011-05-18T15:01:01",
               "status_changed" => "some updated status_changed",
               "user_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, asset_status_track: asset_status_track} do
      conn = put(conn, Routes.asset_status_track_path(conn, :update, asset_status_track), asset_status_track: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete asset_status_track" do
    setup [:create_asset_status_track]

    test "deletes chosen asset_status_track", %{conn: conn, asset_status_track: asset_status_track} do
      conn = delete(conn, Routes.asset_status_track_path(conn, :delete, asset_status_track))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.asset_status_track_path(conn, :show, asset_status_track))
      end
    end
  end

  defp create_asset_status_track(_) do
    asset_status_track = fixture(:asset_status_track)
    %{asset_status_track: asset_status_track}
  end
end
