defmodule Inconn2ServiceWeb.WorkrequestCategoryControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.WorkrequestCategory

  @create_attrs %{
    description: "some description",
    name: "some name"
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name"
  }
  @invalid_attrs %{description: nil, name: nil}

  def fixture(:workrequest_category) do
    {:ok, workrequest_category} = Ticket.create_workrequest_category(@create_attrs)
    workrequest_category
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all workrequest_categories", %{conn: conn} do
      conn = get(conn, Routes.workrequest_category_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create workrequest_category" do
    test "renders workrequest_category when data is valid", %{conn: conn} do
      conn = post(conn, Routes.workrequest_category_path(conn, :create), workrequest_category: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.workrequest_category_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.workrequest_category_path(conn, :create), workrequest_category: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update workrequest_category" do
    setup [:create_workrequest_category]

    test "renders workrequest_category when data is valid", %{conn: conn, workrequest_category: %WorkrequestCategory{id: id} = workrequest_category} do
      conn = put(conn, Routes.workrequest_category_path(conn, :update, workrequest_category), workrequest_category: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workrequest_category_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, workrequest_category: workrequest_category} do
      conn = put(conn, Routes.workrequest_category_path(conn, :update, workrequest_category), workrequest_category: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete workrequest_category" do
    setup [:create_workrequest_category]

    test "deletes chosen workrequest_category", %{conn: conn, workrequest_category: workrequest_category} do
      conn = delete(conn, Routes.workrequest_category_path(conn, :delete, workrequest_category))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.workrequest_category_path(conn, :show, workrequest_category))
      end
    end
  end

  defp create_workrequest_category(_) do
    workrequest_category = fixture(:workrequest_category)
    %{workrequest_category: workrequest_category}
  end
end
