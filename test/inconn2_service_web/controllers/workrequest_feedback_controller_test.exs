defmodule Inconn2ServiceWeb.WorkrequestFeedbackControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.WorkrequestFeedback

  @create_attrs %{
    email: "some email",
    rating: 42,
    site_id: 42,
    user_id: 42,
    work_request_id: 42
  }
  @update_attrs %{
    email: "some updated email",
    rating: 43,
    site_id: 43,
    user_id: 43,
    work_request_id: 43
  }
  @invalid_attrs %{email: nil, rating: nil, site_id: nil, user_id: nil, work_request_id: nil}

  def fixture(:workrequest_feedback) do
    {:ok, workrequest_feedback} = Ticket.create_workrequest_feedback(@create_attrs)
    workrequest_feedback
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all workrequest_feedbacks", %{conn: conn} do
      conn = get(conn, Routes.workrequest_feedback_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create workrequest_feedback" do
    test "renders workrequest_feedback when data is valid", %{conn: conn} do
      conn = post(conn, Routes.workrequest_feedback_path(conn, :create), workrequest_feedback: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.workrequest_feedback_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "some email",
               "rating" => 42,
               "site_id" => 42,
               "user_id" => 42,
               "work_request_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.workrequest_feedback_path(conn, :create), workrequest_feedback: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update workrequest_feedback" do
    setup [:create_workrequest_feedback]

    test "renders workrequest_feedback when data is valid", %{conn: conn, workrequest_feedback: %WorkrequestFeedback{id: id} = workrequest_feedback} do
      conn = put(conn, Routes.workrequest_feedback_path(conn, :update, workrequest_feedback), workrequest_feedback: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workrequest_feedback_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "some updated email",
               "rating" => 43,
               "site_id" => 43,
               "user_id" => 43,
               "work_request_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, workrequest_feedback: workrequest_feedback} do
      conn = put(conn, Routes.workrequest_feedback_path(conn, :update, workrequest_feedback), workrequest_feedback: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete workrequest_feedback" do
    setup [:create_workrequest_feedback]

    test "deletes chosen workrequest_feedback", %{conn: conn, workrequest_feedback: workrequest_feedback} do
      conn = delete(conn, Routes.workrequest_feedback_path(conn, :delete, workrequest_feedback))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.workrequest_feedback_path(conn, :show, workrequest_feedback))
      end
    end
  end

  defp create_workrequest_feedback(_) do
    workrequest_feedback = fixture(:workrequest_feedback)
    %{workrequest_feedback: workrequest_feedback}
  end
end
