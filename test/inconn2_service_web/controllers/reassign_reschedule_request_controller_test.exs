defmodule Inconn2ServiceWeb.ReassignRescheduleRequestControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Reapportion
  alias Inconn2Service.Reapportion.ReassignRescheduleRequest

  @create_attrs %{
    reassign_to_user_id: 42,
    reports_to_user_id: 42,
    requested_user_id: 42,
    reschedule_date: ~D[2010-04-17],
    reschedule_time: ~T[14:00:00]
  }
  @update_attrs %{
    reassign_to_user_id: 43,
    reports_to_user_id: 43,
    requested_user_id: 43,
    reschedule_date: ~D[2011-05-18],
    reschedule_time: ~T[15:01:01]
  }
  @invalid_attrs %{reassign_to_user_id: nil, reports_to_user_id: nil, requested_user_id: nil, reschedule_date: nil, reschedule_time: nil}

  def fixture(:reassign_reschedule_request) do
    {:ok, reassign_reschedule_request} = Reapportion.create_reassign_reschedule_request(@create_attrs)
    reassign_reschedule_request
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all reassign_reschedule_requests", %{conn: conn} do
      conn = get(conn, Routes.reassign_reschedule_request_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create reassign_reschedule_request" do
    test "renders reassign_reschedule_request when data is valid", %{conn: conn} do
      conn = post(conn, Routes.reassign_reschedule_request_path(conn, :create), reassign_reschedule_request: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.reassign_reschedule_request_path(conn, :show, id))

      assert %{
               "id" => id,
               "reassign_to_user_id" => 42,
               "reports_to_user_id" => 42,
               "requested_user_id" => 42,
               "reschedule_date" => "2010-04-17",
               "reschedule_time" => "14:00:00"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.reassign_reschedule_request_path(conn, :create), reassign_reschedule_request: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update reassign_reschedule_request" do
    setup [:create_reassign_reschedule_request]

    test "renders reassign_reschedule_request when data is valid", %{conn: conn, reassign_reschedule_request: %ReassignRescheduleRequest{id: id} = reassign_reschedule_request} do
      conn = put(conn, Routes.reassign_reschedule_request_path(conn, :update, reassign_reschedule_request), reassign_reschedule_request: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.reassign_reschedule_request_path(conn, :show, id))

      assert %{
               "id" => id,
               "reassign_to_user_id" => 43,
               "reports_to_user_id" => 43,
               "requested_user_id" => 43,
               "reschedule_date" => "2011-05-18",
               "reschedule_time" => "15:01:01"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, reassign_reschedule_request: reassign_reschedule_request} do
      conn = put(conn, Routes.reassign_reschedule_request_path(conn, :update, reassign_reschedule_request), reassign_reschedule_request: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete reassign_reschedule_request" do
    setup [:create_reassign_reschedule_request]

    test "deletes chosen reassign_reschedule_request", %{conn: conn, reassign_reschedule_request: reassign_reschedule_request} do
      conn = delete(conn, Routes.reassign_reschedule_request_path(conn, :delete, reassign_reschedule_request))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.reassign_reschedule_request_path(conn, :show, reassign_reschedule_request))
      end
    end
  end

  defp create_reassign_reschedule_request(_) do
    reassign_reschedule_request = fixture(:reassign_reschedule_request)
    %{reassign_reschedule_request: reassign_reschedule_request}
  end
end
