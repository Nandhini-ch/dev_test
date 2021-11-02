defmodule Inconn2ServiceWeb.WorkRequestControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.WorkRequest

  @create_attrs %{
    site_id: 42,
    workrequest_category_id: 42
  }
  @update_attrs %{
    site_id: 43,
    workrequest_category_id: 43
  }
  @invalid_attrs %{site_id: nil, workrequest_category_id: nil}

  def fixture(:work_request) do
    {:ok, work_request} = Ticket.create_work_request(@create_attrs)
    work_request
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all work_requests", %{conn: conn} do
      conn = get(conn, Routes.work_request_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create work_request" do
    test "renders work_request when data is valid", %{conn: conn} do
      conn = post(conn, Routes.work_request_path(conn, :create), work_request: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.work_request_path(conn, :show, id))

      assert %{
               "id" => id,
               "site_id" => 42,
               "workrequest_category_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.work_request_path(conn, :create), work_request: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update work_request" do
    setup [:create_work_request]

    test "renders work_request when data is valid", %{conn: conn, work_request: %WorkRequest{id: id} = work_request} do
      conn = put(conn, Routes.work_request_path(conn, :update, work_request), work_request: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.work_request_path(conn, :show, id))

      assert %{
               "id" => id,
               "site_id" => 43,
               "workrequest_category_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, work_request: work_request} do
      conn = put(conn, Routes.work_request_path(conn, :update, work_request), work_request: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete work_request" do
    setup [:create_work_request]

    test "deletes chosen work_request", %{conn: conn, work_request: work_request} do
      conn = delete(conn, Routes.work_request_path(conn, :delete, work_request))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.work_request_path(conn, :show, work_request))
      end
    end
  end

  defp create_work_request(_) do
    work_request = fixture(:work_request)
    %{work_request: work_request}
  end
end
