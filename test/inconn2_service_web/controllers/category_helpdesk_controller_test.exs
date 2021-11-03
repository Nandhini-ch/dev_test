defmodule Inconn2ServiceWeb.CategoryHelpdeskControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.CategoryHelpdesk

  @create_attrs %{
    user_id: 42
  }
  @update_attrs %{
    user_id: 43
  }
  @invalid_attrs %{user_id: nil}

  def fixture(:category_helpdesk) do
    {:ok, category_helpdesk} = Ticket.create_category_helpdesk(@create_attrs)
    category_helpdesk
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all category_helpdesks", %{conn: conn} do
      conn = get(conn, Routes.category_helpdesk_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create category_helpdesk" do
    test "renders category_helpdesk when data is valid", %{conn: conn} do
      conn = post(conn, Routes.category_helpdesk_path(conn, :create), category_helpdesk: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.category_helpdesk_path(conn, :show, id))

      assert %{
               "id" => id,
               "user_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.category_helpdesk_path(conn, :create), category_helpdesk: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update category_helpdesk" do
    setup [:create_category_helpdesk]

    test "renders category_helpdesk when data is valid", %{conn: conn, category_helpdesk: %CategoryHelpdesk{id: id} = category_helpdesk} do
      conn = put(conn, Routes.category_helpdesk_path(conn, :update, category_helpdesk), category_helpdesk: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.category_helpdesk_path(conn, :show, id))

      assert %{
               "id" => id,
               "user_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, category_helpdesk: category_helpdesk} do
      conn = put(conn, Routes.category_helpdesk_path(conn, :update, category_helpdesk), category_helpdesk: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete category_helpdesk" do
    setup [:create_category_helpdesk]

    test "deletes chosen category_helpdesk", %{conn: conn, category_helpdesk: category_helpdesk} do
      conn = delete(conn, Routes.category_helpdesk_path(conn, :delete, category_helpdesk))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.category_helpdesk_path(conn, :show, category_helpdesk))
      end
    end
  end

  defp create_category_helpdesk(_) do
    category_helpdesk = fixture(:category_helpdesk)
    %{category_helpdesk: category_helpdesk}
  end
end
